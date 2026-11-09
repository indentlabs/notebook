require 'test_helper'

# Daily word counts for documents (revisions are tested in test/models/document_revisions_test.rb)
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
      # Starts today's row at 150. While the late job's debounce window is open, this save queues no
      # job of its own, so the late job is the only one that will see it.
      @document.update!(body: '<p>' + 'word ' * 190 + '</p>')
      late_job.perform_now
    end

    totals = WordCountUpdate.batch_words_written_on_dates(@user, [yesterday, Date.current])
    assert_equal [146, 40], totals.values_at(yesterday, Date.current)
  end

  test "a document's first save after its job stopped running records that writing on the day it was saved" do
    first_day = Date.current - 8.days
    # The stuck lock: one job ran (a row and the document's text, kept as a revision, on the first day)...
    @document.update_columns(body: '<p>Day one words.</p>')
    @document.word_count_updates.create!(user: @user, for_date: first_day, word_count: 3)
    @document.document_revisions.create!(title: 'Novel', body: '<p>Day one words.</p>', cached_word_count: 3,
                                         created_at: first_day.in_time_zone('UTC') + 12.hours, updated_at: first_day.in_time_zone('UTC') + 12.hours)
    # ...then days of writing that no job recorded
    @document.update_columns(body: '<p>Day one words.</p><p>Written while nothing was recorded.</p>', updated_at: 2.days.ago)

    autosave('<p>Day one words.</p><p>Written while nothing was recorded.</p><p>Today.</p>')

    assert_equal 5, WordCountUpdate.words_written_on_date(@user, 2.days.ago.to_date)
    assert_equal 1, WordCountUpdate.words_written_on_date(@user, Date.current)
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
end
