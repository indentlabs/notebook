class DocumentEntityAnalysisJob < ApplicationJob
  queue_as :analysis

  def perform(*args)
    document_entity_id = args.shift

    entity = DocumentEntity.find(document_entity_id)
    return unless entity.present?

    Documents::Analysis::ThirdParty::IbmWatsonService.analyze_entity(document_entity_id)
  end
end
