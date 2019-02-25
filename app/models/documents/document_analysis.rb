class DocumentAnalysis < ApplicationRecord
  belongs_to :document

  serialize :words_per_sentence, Array
  serialize :n_syllable_words,   Hash

  def complete?
    self.completed_at.present?
  end
end
