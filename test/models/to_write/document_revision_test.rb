require 'test_helper'

class DocumentRevisionTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @document = documents(:one)
    @document.update!(user: @user)
    @revision = document_revisions(:one)
  end

  # -- Associations --

  test "belongs to document" do
    assert_respond_to @revision, :document
    assert_equal @document, @revision.document
  end

  # -- user delegation --

  test "user returns the document's user" do
    assert_equal @user, @revision.user
  end

  # -- Attributes --

  test "has title, body, synopsis, and notes_text" do
    assert_equal "The Adventures of Alice", @revision.title
    assert_includes @revision.body, "Alice"
    assert_equal "A story about Alice", @revision.synopsis
    assert_equal "First draft", @revision.notes_text
  end

  # -- acts_as_paranoid --

  test "soft deletes with acts_as_paranoid" do
    @revision.destroy
    assert_not_nil @revision.reload.deleted_at
    assert_nil DocumentRevision.find_by(id: @revision.id)
    assert DocumentRevision.with_deleted.find(@revision.id).present?
  end

  # -- Multiple revisions per document --

  test "document can have multiple revisions" do
    revision_count = @document.document_revisions.count
    assert revision_count >= 2, "Expected at least 2 fixture revisions"
  end

  test "revisions can be ordered by created_at" do
    revisions = @document.document_revisions.order(:created_at)
    assert revisions.first.created_at <= revisions.last.created_at
  end
end
