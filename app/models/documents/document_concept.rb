class DocumentConcept < ApplicationRecord
  belongs_to :document_analysis

  scope :relevant, -> { where('relevance > 0.85') }
end
