# This job is kicked off each time a document is edited. It looks at the document
# text for mentions (e.g. [[Character-123]] and adds that entity as a DocumentEntity).
class DocumentMentionJob < ApplicationJob
  queue_as :analysis # todo do we need to make this lower priority?

  def perform(*args)
    document_id = args.shift

    document = Document.find(document_id)
    return unless document.present?

    analysis = Documents::Analysis::DocumentAnalysisService.create_placeholder_analysis(document)

    # Create document entities for @mentions
    current_entities = document.document_entities.pluck(:entity_type, :entity_id)
    document.body.scan(ContentFormatterService::TOKEN_REGEX).each do |entity_type, id|
      unless current_entities.include? [entity_type, id]
        analysis.document_entities.create(
          entity_type:          entity_type,
          entity_id:            id,
          document_analysis_id: analysis.id
        )

        current_entities << [entity_type, id]
      end
    end
  end
end

# Release note (8/2/19):
# We could pretty easily kick off a DocumentMentionJob for every document in the system
# to start everyone off. We probably want to wait for a window after release to monitor
# page speeds once people start linking quick reference pages, but if all looks well lets
# do it.