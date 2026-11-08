require 'test_helper'

class DocumentRevisionHistoryTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    @user = User.create!(email: 'revision_history@example.com', password: 'password123', time_zone: 'Pacific Time (US & Canada)')
    @document = Document.create!(user: @user, title: 'Novel', body: '<p>Start.</p>')
    sign_in @user
  end

  def paragraphs(count, word = 'Old')
    (1..count).map { |i| "<p>#{word} paragraph number #{i} of the story.</p>" }.join
  end

  def revision!(body, at:, title: 'Novel', words: nil)
    @document.document_revisions.create!(title: title, body: body, created_at: at, updated_at: at,
                                         cached_word_count: words || WordCountService.count(body))
  end

  # -- Show Changes --

  test "Show Changes on a long document shows the paragraph added at the end, and only that" do
    long_draft = paragraphs(2_000) # far past the 50,000 characters the diff used to stop at
    previous = revision!(long_draft, at: 2.days.ago)
    current  = revision!(long_draft + '<p>Written today at the very end.</p>', at: 1.minute.ago)

    get diff_document_document_revision_path(@document, current)
    assert_response :success

    assert_includes response.body, 'Written today at the very end.'
    assert_includes response.body, '+6</span> words'
    # The old last paragraph is unchanged context, not removed and re-added
    refute_match %r{<del>Old paragraph number 2000}, response.body
    refute_match %r{<strong>Old paragraph number}, response.body
    assert previous
  end

  test "Show Changes doesn't show unchanged early text as new after an insertion" do
    long_draft = paragraphs(2_000)
    revision!(long_draft, at: 2.days.ago)
    current = revision!('<p>A new opening line.</p>' + long_draft, at: 1.minute.ago)

    get diff_document_document_revision_path(@document, current)

    assert_includes response.body, '<strong>A new opening line.</strong>'
    refute_match %r{<strong>Old paragraph}, response.body
    refute_match %r{<del>}, response.body
  end

  test "a revision that only changed the title says so instead of repeating the document" do
    revision!('<p>Same text.</p>', at: 1.day.ago, title: 'Old title')
    current = revision!('<p>Same text.</p>', at: 1.hour.ago, title: 'New title')

    get diff_document_document_revision_path(@document, current)

    assert_includes response.body, "The text didn't change in this version. Changed: Title."
  end

  test "swapping a space for a non-breaking space isn't shown as a change" do
    revision!('<p>Hello world.</p>', at: 1.day.ago)
    current = revision!('<p>Hello&nbsp;world.</p>', at: 1.hour.ago)

    get diff_document_document_revision_path(@document, current)

    assert_includes response.body, "The text didn't change"
  end

  test "the first revision shows a preview" do
    first = revision!('<p>In the beginning.</p>', at: 1.day.ago)

    get diff_document_document_revision_path(@document, first)

    assert_includes response.body, 'First Revision Created!'
    assert_includes response.body, '3 words'
  end

  # -- The list --

  test "the last revision on a page is compared with the first one on the next page" do
    61.times { |i| revision!("<p>#{'word ' * (i + 1)}</p>", at: (61 - i).hours.ago) }

    get document_document_revisions_path(@document)
    assert_response :success

    # Every revision on the first page has a Show Changes button, including the 60th
    assert_equal 60, response.body.scan('Show Changes').size
    refute_includes response.body, '+2 words' # the 60th row would show its whole count
    assert_includes response.body, '62</span>'
  end

  test "first backup is the oldest revision, in the writer's time zone" do
    revision!('<p>Oldest.</p>', at: Time.utc(2026, 1, 1, 3, 0)) # Dec 31 in California
    revision!('<p>Newest.</p>', at: 1.hour.ago)

    get document_document_revisions_path(@document)

    assert_includes response.body, 'Dec 31, 2025'
  end

  test "the list doesn't need the full text of every revision" do
    revision!('<p>' + 'word ' * 50_000 + '</p>', at: 1.hour.ago)

    get document_document_revisions_path(@document)
    assert_response :success
  end

  # -- Restore --

  test "restoring keeps the current text as a backup and gives the restored text its own revision" do
    old = revision!('<p>The original opening.</p>', at: 3.days.ago)
    @document.update_columns(body: '<p>A rewritten opening I regret.</p>')

    post restore_document_document_revision_path(@document, old)
    assert_redirected_to edit_document_path(@document)

    bodies = @document.document_revisions.order(:created_at, :id).pluck(:body)
    assert_equal ['<p>The original opening.</p>', '<p>A rewritten opening I regret.</p>', '<p>The original opening.</p>'], bodies
    assert_equal '<p>The original opening.</p>', @document.reload.body

    # The revision job then keeps the restored entry up to date, leaving the backup alone
    perform_enqueued_jobs(only: SaveDocumentRevisionJob)
    @document.update!(body: '<p>The original opening, improved.</p>')
    SaveDocumentRevisionJob.perform_now(@document.id)
    assert_equal '<p>A rewritten opening I regret.</p>', @document.document_revisions.order(:created_at, :id).second.body
    assert_equal '<p>The original opening, improved.</p>', @document.document_revisions.order(:created_at, :id).last.body
  end

  test "restored words aren't counted as written today" do
    old = revision!('<p>' + 'restored ' * 500 + '</p>', at: 3.days.ago)
    @document.update!(body: '<p>Mostly deleted.</p>')
    SaveDocumentRevisionJob.perform_now(@document.id)
    words_before_restore = @user.words_written_today

    post restore_document_document_revision_path(@document, old)
    perform_enqueued_jobs(only: SaveDocumentRevisionJob)
    SaveDocumentRevisionJob.perform_now(@document.id)

    assert_equal words_before_restore, @user.reload.words_written_today
    assert_equal 500, @document.reload.cached_word_count
  end

  test "the revision page's restore button posts to the restore action" do
    revision = revision!('<p>Hello.</p>', at: 1.hour.ago)

    get document_document_revision_path(@document, revision)
    assert_response :success
    assert_includes response.body, restore_document_document_revision_path(@document, revision)
    refute_includes response.body, 'TODO'
  end
end
