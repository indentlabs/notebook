class DocumentAnalysis < ApplicationRecord
  belongs_to :document
  has_many :document_entities,   dependent: :destroy
  has_many :document_concepts,   dependent: :destroy
  has_many :document_categories, dependent: :destroy

  serialize :words_per_sentence, Array
  serialize :n_syllable_words,   Hash

  # usage: analysis.pos_percentage(:adjective) => 23.4
  def pos_percentage(pos_symbol)
    (send(pos_symbol.to_s + '_count').to_f / word_count * 100).round(2)
  end

  def complete?
    self.completed_at.present?
  end

  def has_sentiment_scores?
    [joy_score, sadness_score, fear_score, disgust_score, anger_score].compact.any?
  end
end