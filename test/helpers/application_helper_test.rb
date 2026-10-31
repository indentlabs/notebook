require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper
  
  # Skip loading fixtures to avoid database issues
  self.use_transactional_tests = false
  
  # Use standalone test without fixtures for the helper method
  test "compact_number abbreviates large counts and keeps small counts delimited" do
    assert_equal '0',     compact_number(0)
    assert_equal '168',   compact_number(168)
    assert_equal '5,600', compact_number(5600)
    assert_equal '9,999', compact_number(9999)
    assert_equal '10K',   compact_number(10_000)
    assert_equal '12.3K', compact_number(12_345)
    assert_equal '999K',  compact_number(999_949) # rounds down, never "1000K"
    assert_equal '1.19M', compact_number(1_190_921)
    assert_equal '1.99B', compact_number(1_999_999_999)
  end

  test "word_count_entity_edit_path links timeline events to their parent timeline" do
    timeline = Timeline.new(id: 42)
    event = TimelineEvent.new(id: 7, timeline: timeline)
    assert_equal edit_timeline_path(timeline), word_count_entity_edit_path(event)
  end

  test "word_count_entity_edit_path returns nil for nil or unroutable records" do
    assert_nil word_count_entity_edit_path(nil)
    assert_nil word_count_entity_edit_path(TimelineEvent.new(id: 7))
  end

  test "word_count_entity_edit_path uses the standard edit route when one exists" do
    document = Document.new(id: 3)
    assert_equal edit_document_path(document), word_count_entity_edit_path(document)
  end
end
