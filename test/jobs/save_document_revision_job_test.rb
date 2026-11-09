require 'test_helper'

class SaveDocumentRevisionJobTest < ActiveJob::TestCase
  setup do
    @user = User.create!(email: 'revisions_test@example.com', password: 'password123', time_zone: 'UTC')
    @document = Document.create!(user: @user, title: 'Novel', body: '<p>Once upon a time.</p>')
  end

  # Saves the body the way autosave does, then runs the job that the save queued.
  def autosave(body, client_count: nil)
    params = { body: body }
    params[:cached_word_count] = client_count if client_count
    @document.reload.update!(params)
    SaveDocumentRevisionJob.perform_now(@document.id)
  end

  def row_for(date = Date.current)
    @document.word_count_updates.find_by(for_date: date)
  end

  def revisions
    @document.document_revisions.order(:created_at, :id).to_a
  end

  # -- Word counts --

  test "stores the server's count, not the count the editor sent" do
    # An editor tab opened before the counter changed would still send textContent counts
    autosave('<p>One two three.</p><p>Four five six.</p>', client_count: 5)

    assert_equal 6, @document.reload.cached_word_count
    assert_equal 6, row_for.word_count
  end

  test "today's words are measured from the text before today's first edit" do
    travel_to 3.weeks.ago do
      autosave('<p>An old draft.</p>')
    end
    # Text added since without a row being written (the stuck debounce lock did this for days)
    @document.update_columns(body: '<p>An old draft.</p><p>' + 'pasted ' * 400 + '</p>')

    autosave(@document.body + '<p>Brand new words today.</p>')

    assert_equal 403, row_for.starting_word_count
    assert_equal 407, row_for.word_count
    assert_equal 4, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "an imported document's text isn't credited by its first edit" do
    imported = Document.create!(user: @user, title: 'Imported', body: '<p>' + 'imported ' * 1_000 + '</p>')
    imported.update!(body: imported.body + '<p>My first edit.</p>')
    SaveDocumentRevisionJob.perform_now(imported.id)

    assert_equal 3, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "later saves the same day keep the day's starting count" do
    autosave('<p>Once upon a time, there was a dragon.</p>')
    autosave('<p>Once upon a time, there was a dragon. It slept.</p>')

    assert_equal 4, row_for.starting_word_count
    assert_equal 10, row_for.word_count
    assert_equal 6, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "a row written earlier today the old way keeps what it already credited" do
    # Before this change: yesterday 100 words (old counter), today's row at 130, no starting count
    @document.word_count_updates.create!(user: @user, for_date: Date.current - 1.day, word_count: 100)
    @document.word_count_updates.create!(user: @user, for_date: Date.current, word_count: 130)
    @document.update_columns(body: '<p>' + 'word ' * 135 + '</p>') # the new counter counts 135

    autosave('<p>' + 'word ' * 145 + '</p>')

    # 30 credited earlier today, plus 10 since
    assert_equal 105, row_for.starting_word_count
    assert_equal 40, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "title-only edits don't start a word count day" do
    @document.update!(title: 'Renamed')
    assert_nil row_for
  end

  test "a day whose first change is the title doesn't credit text from before it" do
    # A forum thread saved as a document, never edited before
    forum_doc = Document.create!(user: @user, title: 'Thread', body: '<p>' + 'post ' * 800 + '</p>')
    forum_doc.update!(title: 'Renamed thread')
    SaveDocumentRevisionJob.perform_now(forum_doc.id)
    assert_equal 0, WordCountUpdate.words_written_on_date(@user, Date.current)

    forum_doc.update!(body: forum_doc.body + '<p>My own reply here.</p>')
    SaveDocumentRevisionJob.perform_now(forum_doc.id)
    assert_equal 4, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "a job that runs after midnight doesn't count the new day's words on the old day too" do
    yesterday = Date.current - 1.day
    travel_to(yesterday.in_time_zone('UTC').change(hour: 23, min: 59, sec: 50)) do
      autosave('<p>' + 'word ' * 100 + '</p>')
      @document.update!(body: '<p>' + 'word ' * 150 + '</p>') # its job is still queued at midnight
    end
    late_job = SaveDocumentRevisionJob.new(@document.id)
    late_job.enqueued_at = yesterday.in_time_zone('UTC').change(hour: 23, min: 59, sec: 55).iso8601

    travel_to(Date.current.in_time_zone('UTC').change(hour: 0, min: 0, sec: 20)) do
      @document.update!(body: '<p>' + 'word ' * 190 + '</p>') # starts today's row at 150
      late_job.perform_now
      SaveDocumentRevisionJob.perform_now(@document.id)
    end

    assert_equal 150, row_for(yesterday).word_count
    totals = WordCountUpdate.batch_words_written_on_dates(@user, [yesterday, Date.current])
    assert_equal 190 - 4, totals.values.sum # every word written once (4 were in the document already)
  end

  test "a job queued before the deploy keeps today's earlier credit without the counter change" do
    paragraphs = (1..300).map { |i| "<p>Paragraph #{i} of the novel.</p>" }.join
    @document.update_columns(body: paragraphs)
    # Yesterday and earlier today, counted by the old editor (one word short per paragraph)
    @document.word_count_updates.create!(user: @user, for_date: Date.current - 1.day, word_count: 1_201)
    @document.word_count_updates.create!(user: @user, for_date: Date.current, word_count: 1_301)

    SaveDocumentRevisionJob.perform_now(@document.id) # queued before the deploy, runs after it

    assert_equal 100, WordCountUpdate.words_written_on_date(@user, Date.current)
  end

  test "a document without an owner still gets a revision" do
    @document.update_columns(user_id: nil)
    autosave('<p>Orphaned.</p>')

    assert_nil row_for
    assert_equal 1, revisions.size
  end

  # -- Revisions --

  test "a revision holds the text from the end of its stretch of writing" do
    autosave('<p>First words.</p>')
    travel 1.minute do
      autosave('<p>First words. More words.</p>')
    end
    travel 3.minutes do
      autosave('<p>First words. More words. Last words.</p>')
    end

    assert_equal 1, revisions.size
    assert_equal '<p>First words. More words. Last words.</p>', revisions.last.body
    assert_equal 6, revisions.last.cached_word_count
  end

  test "writing more than a revision window later starts a new revision" do
    autosave('<p>Session one.</p>')
    travel 6.minutes do
      autosave('<p>Session one. Session two.</p>')
    end

    assert_equal ['<p>Session one.</p>', '<p>Session one. Session two.</p>'], revisions.map(&:body)
  end

  # The bug report: "it's showing things I wrote ages ago as being written today and some of the
  # things I did write today aren't there".
  test "a session days later gets its own revision, holding only what was written then" do
    first_session = 9.days.ago
    travel_to(first_session) { autosave('<p>Chapter one.</p>') }
    travel_to(first_session + 2.minutes) { autosave('<p>Chapter one. The end of the first session.</p>') }

    autosave('<p>Chapter one. The end of the first session.</p><p>Today.</p>')
    travel 2.minutes do
      autosave('<p>Chapter one. The end of the first session.</p><p>Today. And more today.</p>')
    end

    old_session, todays_session = revisions
    assert_equal '<p>Chapter one. The end of the first session.</p>', old_session.body
    assert_equal '<p>Chapter one. The end of the first session.</p><p>Today. And more today.</p>', todays_session.body
  end

  test "a large deletion starts a new revision so the deleted text stays in the history" do
    long_text = '<p>' + 'precious ' * 300 + '</p>'
    autosave(long_text)
    travel 1.minute do
      autosave('<p>Oops.</p>')
    end

    assert_equal [long_text, '<p>Oops.</p>'], revisions.map(&:body)
  end

  test "pasting over text starts a new revision even if the count stays the same" do
    original = '<p>' + 'original ' * 300 + '</p>'
    autosave(original)
    travel 1.minute do
      autosave('<p>' + 'replacement ' * 320 + '</p>')
    end

    assert_equal original, revisions.first.body
    assert_equal 2, revisions.size
  end

  test "a revision is never changed once a newer one has been made, even if the newer one is deleted" do
    autosave('<p>' + 'first ' * 200 + '</p>')
    travel 1.minute do
      autosave('<p>Short.</p>') # a large deletion starts a second revision
    end
    revisions.last.destroy

    travel 2.minutes do
      autosave('<p>' + 'first ' * 200 + 'more.</p>')
    end

    assert_equal '<p>' + 'first ' * 200 + '</p>', revisions.first.body
  end

  test "small deletions update the open revision" do
    autosave('<p>' + 'word ' * 50 + 'typo</p>')
    travel 1.minute do
      autosave('<p>' + 'word ' * 50 + '</p>')
    end

    assert_equal 1, revisions.size
  end
end
