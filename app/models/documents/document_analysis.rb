class DocumentAnalysis < ApplicationRecord
  belongs_to :document
  has_many :document_entities

  serialize :words_per_sentence, Array
  serialize :n_syllable_words,   Hash

  def complete?
    self.completed_at.present?
  end
end
