require 'test_helper'

class Documents::Analysis::ReadabilityServiceTest < ActiveSupport::TestCase
  # -- readability_score_category --

  test "readability_score_category returns Hard for scores 0-35" do
    assert_equal 'Hard', Documents::Analysis::ReadabilityService.readability_score_category(0)
    assert_equal 'Hard', Documents::Analysis::ReadabilityService.readability_score_category(20)
    assert_equal 'Hard', Documents::Analysis::ReadabilityService.readability_score_category(35)
  end

  test "readability_score_category returns Average for scores 36-65" do
    assert_equal 'Average', Documents::Analysis::ReadabilityService.readability_score_category(36)
    assert_equal 'Average', Documents::Analysis::ReadabilityService.readability_score_category(50)
    assert_equal 'Average', Documents::Analysis::ReadabilityService.readability_score_category(65)
  end

  test "readability_score_category returns Easy for scores 66-100" do
    assert_equal 'Easy', Documents::Analysis::ReadabilityService.readability_score_category(66)
    assert_equal 'Easy', Documents::Analysis::ReadabilityService.readability_score_category(80)
    assert_equal 'Easy', Documents::Analysis::ReadabilityService.readability_score_category(100)
  end

  # -- readability_score_text --

  test "readability_score_text returns Nice for easy scores" do
    analysis = document_analyses(:two)
    analysis.readability_score = 80
    analysis.combined_average_reading_level = 3.0

    text = Documents::Analysis::ReadabilityService.readability_score_text(analysis)
    assert_includes text, "Nice!"
    assert_includes text, "easily understandable"
  end

  test "readability_score_text returns Not bad for average scores" do
    analysis = document_analyses(:one)
    analysis.readability_score = 55
    analysis.combined_average_reading_level = 8.5

    text = Documents::Analysis::ReadabilityService.readability_score_text(analysis)
    assert_includes text, "Not bad!"
    assert_includes text, "understandable"
  end

  test "readability_score_text returns improvement suggestion for hard scores" do
    analysis = document_analyses(:one)
    analysis.readability_score = 20
    analysis.combined_average_reading_level = 12.0

    text = Documents::Analysis::ReadabilityService.readability_score_text(analysis)
    assert_includes text, "could definitely be improved"
  end

  # -- combined_average_grade_level --

  test "combined_average_grade_level returns nil with fewer than 3 scores" do
    analysis = DocumentAnalysis.new(
      automated_readability_index: 5.0,
      coleman_liau_index: 6.0
    )
    assert_nil Documents::Analysis::ReadabilityService.combined_average_grade_level(analysis)
  end

  test "combined_average_grade_level trims outliers and averages" do
    analysis = DocumentAnalysis.new(
      automated_readability_index: 5.0,
      coleman_liau_index: 6.0,
      flesch_kincaid_grade_level: 7.0,
      forcast_grade_level: 8.0,
      gunning_fog_index: 9.0,
      smog_grade: 10.0
    )
    result = Documents::Analysis::ReadabilityService.combined_average_grade_level(analysis)
    assert_not_nil result
    assert result.between?(0, 16)
  end

  # -- readability_score --

  test "readability_score returns nil with fewer than 3 scores" do
    analysis = DocumentAnalysis.new(
      coleman_liau_index: 5.0,
      flesch_kincaid_reading_ease: 60.0
    )
    assert_nil Documents::Analysis::ReadabilityService.readability_score(analysis)
  end

  test "readability_score returns value clamped to 0-100" do
    analysis = DocumentAnalysis.new(
      coleman_liau_index: 5.0,
      flesch_kincaid_reading_ease: 60.0,
      forcast_grade_level: 8.0,
      gunning_fog_index: 10.0,
      smog_grade: 9.0,
      linsear_write_grade: 7.0
    )
    result = Documents::Analysis::ReadabilityService.readability_score(analysis)
    assert_not_nil result
    assert result.between?(0, 100)
  end

  # -- forcast_grade_level --

  test "forcast_grade_level returns 1 for empty document" do
    doc = OpenStruct.new(words: [], words_with_syllables: ->(_) { [] })
    # Allow method call with argument
    doc.define_singleton_method(:words_with_syllables) { |_| [] }
    result = Documents::Analysis::ReadabilityService.forcast_grade_level(doc)
    assert_equal 1, result
  end

  # -- Edge cases for zero-length documents --

  test "coleman_liau_index returns 1 for empty document" do
    doc = OpenStruct.new(words: [], sentences: [], characters: [])
    result = Documents::Analysis::ReadabilityService.coleman_liau_index(doc)
    assert_equal 1, result
  end

  test "automated_readability_index returns 1 for empty document" do
    doc = OpenStruct.new(words: [], sentences: [], characters: [])
    result = Documents::Analysis::ReadabilityService.automated_readability_index(doc)
    assert_equal 1, result
  end

  test "gunning_fog_index returns 1 for empty document" do
    doc = OpenStruct.new(words: [], sentences: [], complex_words: [])
    result = Documents::Analysis::ReadabilityService.gunning_fog_index(doc)
    assert_equal 1, result
  end

  test "smog_grade returns 1 for empty document" do
    doc = OpenStruct.new(sentences: [], complex_words: [])
    result = Documents::Analysis::ReadabilityService.smog_grade(doc)
    assert_equal 1, result
  end
end
