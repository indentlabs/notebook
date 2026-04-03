require 'test_helper'

class DocumentEntityTest < ActiveSupport::TestCase
  def setup
    @entity = document_entities(:one)
    @location_entity = document_entities(:two)
  end

  # -- Associations --

  test "belongs to document_analysis" do
    assert_respond_to @entity, :document_analysis
    assert_equal document_analyses(:one), @entity.document_analysis
  end

  test "has one document through document_analysis" do
    assert_respond_to @entity, :document
  end

  # -- emotions --

  test "emotions returns hash of emotion scores" do
    emotions = @entity.emotions
    assert_kind_of Hash, emotions
    assert_equal [:sadness, :joy, :fear, :disgust, :anger], emotions.keys
    assert_equal 0.7, emotions[:joy]
    assert_equal 0.1, emotions[:sadness]
  end

  # -- dominant_emotion --

  test "dominant_emotion returns emotions sorted descending by score" do
    result = @entity.dominant_emotion
    assert_equal :joy, result.first.first
  end

  test "dominant_emotion returns unknown when all scores are nil" do
    @entity.joy_score = nil
    @entity.sadness_score = nil
    @entity.fear_score = nil
    @entity.disgust_score = nil
    @entity.anger_score = nil
    result = @entity.dominant_emotion
    assert_equal [[:unknown, 1]], result
  end

  test "dominant_emotion returns unknown when all scores are zero" do
    @entity.joy_score = 0
    @entity.sadness_score = 0
    @entity.fear_score = 0
    @entity.disgust_score = 0
    @entity.anger_score = 0
    result = @entity.dominant_emotion
    assert_equal [[:unknown, 1]], result
  end

  # -- recessive_emotion --

  test "recessive_emotion returns emotions sorted ascending by score" do
    result = @entity.recessive_emotion
    # Lowest score first
    assert_equal :disgust, result.first.first
  end

  test "recessive_emotion returns unknown when scores are nil" do
    @entity.joy_score = nil
    @entity.sadness_score = nil
    @entity.fear_score = nil
    @entity.disgust_score = nil
    @entity.anger_score = nil
    result = @entity.recessive_emotion
    assert_equal [[:unknown, 1]], result
  end

  # -- linked_name_if_possible --

  test "linked_name_if_possible returns text when entity is not linked" do
    @entity.entity_id = nil
    assert_equal "Alice", @entity.linked_name_if_possible
  end

  # -- entity_relation --

  test "entity_relation pluralizes and downcases entity_type" do
    @entity.entity_type = "Character"
    assert_equal "characters", @entity.entity_relation

    @location_entity.entity_type = "Location"
    assert_equal "locations", @location_entity.entity_relation
  end

  # -- entity_match? --

  test "entity_match? returns true for exact name match" do
    mock_entity = OpenStruct.new(name: "Alice")
    assert @entity.entity_match?(mock_entity)
  end

  test "entity_match? returns false for name mismatch" do
    mock_entity = OpenStruct.new(name: "Bob")
    assert_not @entity.entity_match?(mock_entity)
  end

  test "entity_match? returns nil if entity doesn't respond to name" do
    mock_entity = Object.new
    assert_nil @entity.entity_match?(mock_entity)
  end

  # -- document_owner --

  test "document_owner returns the user of the document" do
    user = users(:one)
    doc = documents(:one)
    doc.update!(user: user)

    assert_equal user, @entity.document_owner
  end

  # -- Validations --

  test "validates uniqueness of entity_id within scope when entity_id present" do
    @entity.update!(entity_type: "Character", entity_id: 999)

    duplicate = DocumentEntity.new(
      document_analysis: @entity.document_analysis,
      entity_type: "Character",
      entity_id: 999,
      text: "Duplicate"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:entity_id], "is already linked to this document"
  end

  test "allows duplicate entity_id when entity_id is nil" do
    entity_a = DocumentEntity.new(
      document_analysis: @entity.document_analysis,
      entity_type: "Character",
      entity_id: nil,
      text: "Unlinked A"
    )
    entity_b = DocumentEntity.new(
      document_analysis: @entity.document_analysis,
      entity_type: "Character",
      entity_id: nil,
      text: "Unlinked B"
    )
    assert entity_a.valid?
    assert entity_b.valid?
  end
end
