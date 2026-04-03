require 'test_helper'

class DocumentConceptTest < ActiveSupport::TestCase
  def setup
    @concept = document_concepts(:one)
    @low_relevance_concept = document_concepts(:low_relevance)
  end

  # -- Associations --

  test "belongs to document_analysis" do
    assert_respond_to @concept, :document_analysis
    assert_equal document_analyses(:one), @concept.document_analysis
  end

  # -- Scopes --

  test "relevant scope returns concepts with relevance above 0.85" do
    relevant = DocumentConcept.relevant
    assert_includes relevant, @concept
    assert_not_includes relevant, @low_relevance_concept
  end

  test "relevant scope excludes concepts at exactly 0.85" do
    @low_relevance_concept.update!(relevance: 0.85)
    assert_not_includes DocumentConcept.relevant, @low_relevance_concept
  end

  test "relevant scope includes concepts above 0.85" do
    @low_relevance_concept.update!(relevance: 0.86)
    assert_includes DocumentConcept.relevant, @low_relevance_concept
  end

  # -- Attributes --

  test "has text, relevance, and reference_link attributes" do
    assert_equal "Alice in Wonderland", @concept.text
    assert_in_delta 0.96, @concept.relevance, 0.01
    assert_equal "http://dbpedia.org/resource/Alice_in_Wonderland", @concept.reference_link
  end
end
