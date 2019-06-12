require 'active_support/concern'

module IsContentPage
  extend ActiveSupport::Concern

  included do
    include HasAttributes
    include HasPrivacy
    include HasContentGroupers
    include HasImageUploads
    include HasChangelog
    include HasPageTags

    has_many :document_entities, as: :entity
    attr_accessor :document_entity_id
    def documents
      analysis_ids = DocumentAnalysis.where(
        id: document_entities.pluck(:document_analysis_id)
      ).pluck(:id)
      Document.where(id: analysis_ids)
    end
  end
end
