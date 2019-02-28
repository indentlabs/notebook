class DocumentAnalysis < ApplicationRecord
  belongs_to :document
  has_many :document_entities
  has_many :document_concepts
  has_many :document_categories

  serialize :words_per_sentence, Array
  serialize :n_syllable_words,   Hash

  def complete?
    self.completed_at.present?
  end
end
