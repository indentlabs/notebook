require 'test_helper'

class DocumentCategoryTest < ActiveSupport::TestCase
  def setup
    @category = document_categories(:one)
    @low_score_category = document_categories(:low_score)
  end

  # -- Associations --

  test "belongs to document_analysis" do
    assert_respond_to @category, :document_analysis
    assert_equal document_analyses(:one), @category.document_analysis
  end

  # -- Scopes --

  test "relevant scope returns categories with score above 0.85" do
    relevant = DocumentCategory.relevant
    assert_includes relevant, @category
    assert_not_includes relevant, @low_score_category
  end

  test "relevant scope excludes categories at exactly 0.85" do
    @low_score_category.update!(score: "0.85")
    assert_not_includes DocumentCategory.relevant, @low_score_category
  end

  # -- parent_categories --

  test "parent_categories returns intermediate path segments" do
    # label: "/art and entertainment/books and literature/children's literature"
    assert_equal "art and entertainment/books and literature", @category.parent_categories
  end

  test "parent_categories returns single segment for two-level label" do
    @category.label = "/art and entertainment/books"
    assert_equal "art and entertainment", @category.parent_categories
  end

  test "parent_categories returns empty string for single-level label" do
    @category.label = "/art and entertainment"
    assert_equal "", @category.parent_categories
  end

  # -- terminal_category --

  test "terminal_category returns last path segment" do
    assert_equal "children's literature", @category.terminal_category
  end

  test "terminal_category works for single-level label" do
    @category.label = "/science"
    assert_equal "science", @category.terminal_category
  end

  test "terminal_category works for deeply nested label" do
    @category.label = "/a/b/c/d/e"
    assert_equal "e", @category.terminal_category
  end
end
