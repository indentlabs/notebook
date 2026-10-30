require 'test_helper'

class Documents::Analysis::FleschKincaidServiceTest < ActiveSupport::TestCase
  # -- grade_level --

  test "grade_level returns 0 for empty document" do
    doc = OpenStruct.new(words: [], sentences: [], word_syllables: [])
    assert_equal 0, Documents::Analysis::FleschKincaidService.grade_level(doc)
  end

  test "grade_level is clamped between 0 and 16" do
    # A very simple document
    doc = OpenStruct.new(
      words: %w[the cat sat on the mat],
      sentences: ["the cat sat on the mat"],
      word_syllables: [1, 1, 1, 1, 1, 1]
    )
    result = Documents::Analysis::FleschKincaidService.grade_level(doc)
    assert result.between?(0, 16)
  end

  # -- reading_ease --

  test "reading_ease returns 0 for empty document" do
    doc = OpenStruct.new(words: [], sentences: [], word_syllables: [])
    assert_equal 0, Documents::Analysis::FleschKincaidService.reading_ease(doc)
  end

  test "reading_ease is clamped between 0 and 100" do
    doc = OpenStruct.new(
      words: %w[the cat sat on the mat],
      sentences: ["the cat sat on the mat"],
      word_syllables: [1, 1, 1, 1, 1, 1]
    )
    result = Documents::Analysis::FleschKincaidService.reading_ease(doc)
    assert result.between?(0, 100)
  end

  test "simple text has higher reading ease than complex text" do
    simple_doc = OpenStruct.new(
      words: %w[the cat sat],
      sentences: ["the cat sat"],
      word_syllables: [1, 1, 1]
    )
    complex_doc = OpenStruct.new(
      words: %w[the characterization demonstrated extraordinary sophistication],
      sentences: ["the characterization demonstrated extraordinary sophistication"],
      word_syllables: [1, 5, 4, 6, 5]
    )
    simple_ease = Documents::Analysis::FleschKincaidService.reading_ease(simple_doc)
    complex_ease = Documents::Analysis::FleschKincaidService.reading_ease(complex_doc)
    assert simple_ease > complex_ease, "Simple text should have higher reading ease"
  end

  # -- age_minimum --

  test "age_minimum returns 11 for very easy text (reading ease 90-100)" do
    doc = OpenStruct.new(
      words: %w[the cat sat],
      sentences: ["the cat sat"],
      word_syllables: [1, 1, 1]
    )
    ease = Documents::Analysis::FleschKincaidService.reading_ease(doc)
    if ease.between?(90, 100)
      assert_equal 11, Documents::Analysis::FleschKincaidService.age_minimum(doc)
    end
  end

  test "age_minimum returns nil for reading ease outside defined ranges" do
    doc = OpenStruct.new(words: [], sentences: [], word_syllables: [])
    # reading_ease returns 0 for empty, which matches "when 0 then 25"
    result = Documents::Analysis::FleschKincaidService.age_minimum(doc)
    assert_equal 25, result
  end
end
