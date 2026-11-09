require 'test_helper'
require 'minitest/mock'

# Revision history is append-only: a save keeps the version it replaces when nothing has been kept
# for a while, or when it removes a lot of text (Document#keep_replaced_version!).
class DocumentRevisionSnapshotsTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: 'snapshots_test@example.com', password: 'password123', time_zone: 'UTC')
    travel_to(1.day.ago) { @document = Document.create!(user: @user, title: 'Novel', body: '<p>Once upon a time.</p>') }
  end

  def save(body, **changes)
    @document.reload.update!(body: body, **changes)
  end

  def revisions
    @document.document_revisions.order(:created_at, :id).to_a
  end

  test "the first save after a break keeps the version it replaces, dated when it was written" do
    save('<p>Once upon a time, a dragon.</p>')

    assert_equal ['<p>Once upon a time.</p>'], revisions.map(&:body)
    assert_in_delta 1.day.ago, revisions.first.updated_at, 5.seconds
  end

  # The bug report: "it's showing things I wrote ages ago as being written today and some of the
  # things I did write today aren't there"
  test "a session days later keeps the end of the previous session, holding only what was written then" do
    first_session = 9.days.ago
    travel_to(first_session) { save('<p>Chapter one.</p>') }
    travel_to(first_session + 2.minutes) { save('<p>Chapter one. The end of the first session.</p>') }

    save('<p>Chapter one. The end of the first session.</p><p>Today.</p>')
    travel(2.minutes) { save('<p>Chapter one. The end of the first session.</p><p>Today. And more today.</p>') }

    end_of_first_session = revisions.last
    assert_equal '<p>Chapter one. The end of the first session.</p>', end_of_first_session.body
    assert_in_delta first_session + 2.minutes, end_of_first_session.updated_at, 5.seconds
    # Today's writing is the current version, not in any revision yet
    refute revisions.any? { |revision| revision.body.include?('Today') }
  end

  test "writing for a long stretch keeps a version every few minutes" do
    12.times { |minute| travel_to(Time.current + minute.minutes) { save("<p>#{'word ' * (minute + 1)}</p>") } }

    assert_equal 3, revisions.size # the original, then about every five minutes
  end

  test "small edits within a few minutes don't keep a version" do
    save('<p>Once upon a time, a dragon.</p>') # keeps the original
    travel(1.minute) { save('<p>Once upon a time, a red dragon.</p>') }
    travel(2.minutes) { save('<p>Once upon a time, a big red dragon.</p>') }

    assert_equal 1, revisions.size
  end

  test "a large deletion keeps the text it removed" do
    long_text = '<p>' + 'precious ' * 300 + '</p>'
    save(long_text)
    travel(1.minute) { save('<p>Oops.</p>') }

    assert_includes revisions.map(&:body), long_text
  end

  test "pasting over text keeps the replaced text even when the count stays the same" do
    original = '<p>' + 'original ' * 300 + '</p>'
    save(original)
    travel(1.minute) { save('<p>' + 'replacement ' * 320 + '</p>') }

    assert_includes revisions.map(&:body), original
  end

  test "an old tab saving over newer text keeps the newer text in the history" do
    save('<p>Once upon a time.</p><p>' + 'Written on my phone just now. ' * 20 + '</p>')
    travel(30.seconds) { save('<p>Once upon a time.</p>') } # the laptop tab, opened this morning

    assert revisions.any? { |revision| revision.body.include?('Written on my phone') }
  end

  test "a status change after a break keeps the end of the last session with its own date" do
    travel_to(2.days.ago) { save('<p>The end of a session.</p>') }

    @document.reload.update!(status: 'revising')
    save('<p>The end of a session. A new one.</p>')

    kept = revisions.find { |revision| revision.body == '<p>The end of a session.</p>' }
    assert kept
    assert_in_delta 2.days.ago, kept.updated_at, 1.minute
    assert_equal 1, revisions.count { |revision| revision.body == '<p>The end of a session.</p>' }
  end

  test "revisions are never changed after they are kept" do
    save('<p>Once upon a time, a dragon.</p>')
    kept = revisions.first
    original_attributes = kept.attributes

    travel(10.minutes) { save('<p>Something else entirely, written much later on.</p>') }

    assert_equal original_attributes, kept.reload.attributes
  end

  test "a kept version is counted on the server" do
    @document.update_columns(cached_word_count: 1) # an old editor's count
    save('<p>Once upon a time, a dragon.</p>')

    assert_equal 4, revisions.first.cached_word_count
  end

  test "keeping a version never fails the save" do
    @document.reload
    @document.stub(:keep_version!, ->(*, **) { raise ActiveRecord::StatementInvalid, 'disk full' }) do
      assert @document.update!(body: '<p>Saved anyway.</p>')
    end
    assert_equal '<p>Saved anyway.</p>', @document.reload.body
  end
end
