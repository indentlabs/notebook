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
end
