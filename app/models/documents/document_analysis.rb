class DocumentAnalysis < ApplicationRecord
  belongs_to :document
  has_many :document_entities,   dependent: :destroy
  has_many :document_concepts,   dependent: :destroy
  has_many :document_categories, dependent: :destroy

  serialize :words_per_sentence, Array
  serialize :n_syllable_words,   Hash

  def complete?
    self.completed_at.present?
  end
end