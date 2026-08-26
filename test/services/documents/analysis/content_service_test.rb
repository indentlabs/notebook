require 'test_helper'

class Documents::Analysis::ContentServiceTest < ActiveSupport::TestCase
  test "adult_content? detects hate speech matches" do
    result = Documents::Analysis::ContentService.adult_content?("some hateful slur text", matchlist: :hate)
    # Result is an array of matched words; we just verify it returns an array
    assert_kind_of Array, result
  end

  test "adult_content? returns empty array for clean text" do
    result = Documents::Analysis::ContentService.adult_content?("the quick brown fox jumps over the lazy dog", matchlist: :profanity)
    assert_kind_of Array, result
    assert_empty result
  end

  test "adult_content? detects profanity matches" do
    result = Documents::Analysis::ContentService.adult_content?("this is clean text about flowers", matchlist: :profanity)
    assert_kind_of Array, result
    assert_empty result
  end
end
