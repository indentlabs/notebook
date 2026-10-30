require 'test_helper'

class WordCountServiceTest < ActiveSupport::TestCase
  # Basic word counting
  test "counts simple words correctly" do
    assert_equal 3, WordCountService.count("hello world today")
  end

  test "returns 0 for blank text" do
    assert_equal 0, WordCountService.count("")
    assert_equal 0, WordCountService.count(nil)
    assert_equal 0, WordCountService.count("   ")
  end

  # Forward slash handling
  test "counts path/to/file as 3 words" do
    assert_equal 3, WordCountService.count("path/to/file")
  end

  test "counts URL paths as multiple words" do
    # example/com/page/one splits into 4 words, plus "Visit" and "today" = 6
    assert_equal 6, WordCountService.count("Visit example/com/page/one today")
  end

  test "preserves dates with slashes as single tokens" do
    # Dates like 01/02/2024 should not be split
    result = WordCountService.count("Meeting on 01/02/2024")
    # "Meeting" + "on" + "01/02/2024" (preserved) = 3 words
    assert_equal 3, result
  end

  # Backslash handling
  test "counts backslash paths as multiple words" do
    assert_equal 3, WordCountService.count("path\\to\\file")
  end

  # Punctuation handling
  test "ignores ellipsis" do
    assert_equal 2, WordCountService.count("hello ... world")
    assert_equal 2, WordCountService.count("hello.... world")
  end

  test "ignores dashed lines" do
    assert_equal 2, WordCountService.count("hello --- world")
    assert_equal 2, WordCountService.count("hello -- world")
  end

  test "ignores underscore lines" do
    assert_equal 2, WordCountService.count("hello ___ world")
  end

  test "ignores stray punctuation" do
    assert_equal 2, WordCountService.count("hello ! world")
    assert_equal 2, WordCountService.count("@ hello # world")
  end

  # Contractions and hyphenated words
  test "counts contractions as one word" do
    assert_equal 2, WordCountService.count("don't worry")
    assert_equal 2, WordCountService.count("I'm happy")
  end

  test "counts hyphenated words as one word" do
    assert_equal 2, WordCountService.count("well-known fact")
    assert_equal 1, WordCountService.count("mother-in-law")
  end

  # Numbers
  test "counts numbers as words" do
    assert_equal 3, WordCountService.count("chapter 42 begins")
    assert_equal 2, WordCountService.count("100 words")
  end

  # HTML handling
  test "strips HTML tags before counting" do
    assert_equal 2, WordCountService.count("<p>hello</p> <strong>world</strong>")
    assert_equal 3, WordCountService.count("<div><span>one</span> two three</div>")
  end

  # Edge cases
  test "handles multiple spaces correctly" do
    assert_equal 3, WordCountService.count("hello    world    today")
  end

  test "handles newlines and tabs" do
    assert_equal 3, WordCountService.count("hello\nworld\ttoday")
  end

  test "handles mixed complex content" do
    text = "The path/to/file contains don't and well-known words... Also 42 items!"
    # "The" + "path" + "to" + "file" + "contains" + "don't" + "and" +
    # "well-known" + "words" + "Also" + "42" + "items" = 12 words
    # (ellipsis and ! are ignored)
    assert_equal 12, WordCountService.count(text)
  end

  # Large document handling (memory-efficient lightweight counter)
  test "handles large documents without memory issues" do
    large_text = "word " * 60_000
    count = WordCountService.count(large_text)
    assert_equal 60_000, count
  end

  test "lightweight counter matches gem for forward slash" do
    assert_lightweight_matches_gem("path/to/file", 3)
  end

  test "lightweight counter matches gem for date" do
    assert_lightweight_matches_gem("01/02/2024", 1)
  end

  test "lightweight counter matches gem for contraction" do
    assert_lightweight_matches_gem("don't", 1)
  end

  test "lightweight counter matches gem for hyphenated word" do
    assert_lightweight_matches_gem("well-known", 1)
  end

  test "lightweight counter matches gem for HTML" do
    assert_lightweight_matches_gem("<p>HTML</p> text", 2)
  end

  test "lightweight counter matches gem for ellipsis" do
    assert_lightweight_matches_gem("...", 0)
  end

  test "lightweight counter matches gem for dashed line" do
    assert_lightweight_matches_gem("---", 0)
  end

  test "lightweight counter matches gem for underscore line" do
    assert_lightweight_matches_gem("___", 0)
  end

  test "lightweight counter matches gem for stray punctuation" do
    # Note: "@#$" as a single token is counted by the gem as 1 word,
    # but separated punctuation like "@ hello # world" ignores the @ and #
    assert_lightweight_matches_gem("@ #", 0)
  end

  test "lightweight counter matches gem for backslash" do
    backslash_text = "path\\to\\file"
    assert_lightweight_matches_gem(backslash_text, 3)
  end

  test "count_with_fallback returns count on success" do
    assert_equal 3, WordCountService.count_with_fallback("hello world today")
  end

  test "count_with_fallback falls back to simple count on error" do
    # Test simple_count directly via reflection
    simple_result = WordCountService.send(:simple_count, "<p>hello</p> world")
    assert_equal 2, simple_result
  end

  test "simple_count strips HTML and splits on whitespace" do
    assert_equal 2, WordCountService.send(:simple_count, "<p>hello</p> <b>world</b>")
    assert_equal 0, WordCountService.send(:simple_count, nil)
    assert_equal 0, WordCountService.send(:simple_count, "")
  end

  test "chunked counting handles very large documents" do
    # Create a document larger than CHUNK_SIZE * 3 to trigger chunked counting
    large_text = "word " * 100_000
    count = WordCountService.count(large_text)
    assert_equal 100_000, count
  end

  test "chunked counting preserves word boundaries" do
    # Create text where words might be split at chunk boundaries
    # Use a mix of short and long words
    words = ["the", "quick", "brown", "fox", "jumps", "over", "lazy", "dog"]
    text = (words * 15_000).join(" ")
    count = WordCountService.count(text)
    assert_equal 15_000 * 8, count
  end

  private

  def assert_lightweight_matches_gem(text, expected)
    gem_count = WordCountAnalyzer::Counter.new(**WordCountService::COUNTER_OPTIONS).count(text)
    assert_equal expected, gem_count, "Gem mismatch for: #{text.inspect}"

    # Force lightweight counter by making text appear large
    large_text = text + (" x" * 60_000)
    service_count = WordCountService.count(large_text) - 60_000
    assert_equal expected, service_count, "Lightweight counter mismatch for: #{text.inspect}"
  end
end
