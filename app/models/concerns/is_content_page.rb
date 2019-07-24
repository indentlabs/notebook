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
      document_ids = DocumentAnalysis.where(
        id: document_entities.pluck(:document_analysis_id)
      ).pluck(:document_id)
      Document.where(id: document_ids)
    end
  end
end
