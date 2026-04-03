require 'test_helper'

class DocumentAnalysisTest < ActiveSupport::TestCase
  def setup
    @analysis = document_analyses(:one)
    @incomplete_analysis = document_analyses(:two)
  end

  # -- Associations --

  test "belongs to document" do
    assert_respond_to @analysis, :document
    assert_equal documents(:one), @analysis.document
  end

  test "has many document_entities" do
    assert_respond_to @analysis, :document_entities
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @analysis.document_entities
  end

  test "has many document_concepts" do
    assert_respond_to @analysis, :document_concepts
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @analysis.document_concepts
  end

  test "has many document_categories" do
    assert_respond_to @analysis, :document_categories
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @analysis.document_categories
  end

  test "destroying analysis destroys associated entities" do
    entity_count = @analysis.document_entities.count
    assert entity_count > 0

    assert_difference('DocumentEntity.count', -entity_count) do
      @analysis.destroy
    end
  end

  test "destroying analysis destroys associated concepts" do
    concept_count = @analysis.document_concepts.count
    assert concept_count > 0

    assert_difference('DocumentConcept.count', -concept_count) do
      @analysis.destroy
    end
  end

  test "destroying analysis destroys associated categories" do
    category_count = @analysis.document_categories.count
    assert category_count > 0

    assert_difference('DocumentCategory.count', -category_count) do
      @analysis.destroy
    end
  end

  # -- pos_percentage --

  test "pos_percentage calculates correct percentage for adjectives" do
    # 5 adjectives out of 65 words = 7.69%
    result = @analysis.pos_percentage(:adjective)
    assert_in_delta 7.69, result, 0.01
  end

  test "pos_percentage calculates correct percentage for nouns" do
    # 15 nouns out of 65 words = 23.08%
    result = @analysis.pos_percentage(:noun)
    assert_in_delta 23.08, result, 0.01
  end

  test "pos_percentage returns 0.0 when word_count is nil" do
    @analysis.word_count = nil
    assert_equal 0.0, @analysis.pos_percentage(:noun)
  end

  test "pos_percentage returns 0.0 when word_count is zero" do
    @analysis.word_count = 0
    assert_equal 0.0, @analysis.pos_percentage(:noun)
  end

  # -- complete? --

  test "complete? returns true when completed_at is present" do
    assert @analysis.complete?
  end

  test "complete? returns false when completed_at is nil" do
    assert_not @incomplete_analysis.complete?
  end

  # -- has_sentiment_scores? --

  test "has_sentiment_scores? returns true when any sentiment score is present" do
    assert @analysis.has_sentiment_scores?
  end

  test "has_sentiment_scores? returns false when all scores are nil" do
    @analysis.joy_score = nil
    @analysis.sadness_score = nil
    @analysis.fear_score = nil
    @analysis.disgust_score = nil
    @analysis.anger_score = nil
    assert_not @analysis.has_sentiment_scores?
  end

  # -- Class display methods --

  test "icon returns bar_chart" do
    assert_equal 'bar_chart', DocumentAnalysis.icon
  end

  test "text_color returns orange" do
    assert_equal 'text-orange-500', DocumentAnalysis.text_color
  end

  test "color returns orange background" do
    assert_equal 'bg-orange-500', DocumentAnalysis.color
  end

  # -- Serialized attributes --

  test "words_per_sentence is serialized as Array" do
    assert_kind_of Array, @analysis.words_per_sentence
  end

  test "n_syllable_words is serialized as Hash" do
    assert_kind_of Hash, @analysis.n_syllable_words
  end
end
