class DocumentAnalysis < ApplicationRecord
  belongs_to :document

  serialize :words_per_sentence, Array
  serialize :n_syllable_words,   Hash
end
