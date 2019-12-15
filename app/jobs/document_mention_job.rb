# This job is kicked off each time a document is edited. It looks at the document
# text for mentions (e.g. [[Character-123]] and adds that entity as a DocumentEntity).
class DocumentMentionJob < ApplicationJob
  queue_as :mentions

  def perform(*args)
    document_id = args.shift

    document = Document.find_by(id: document_id)
    return unless document.present?
    return if document.body.nil? || document.body.empty?

    analysis = Documents::Analysis::DocumentAnalysisService.create_placeholder_analysis(document)

    # Create document entities for @mentions
    current_entities = document.document_entities.pluck(:entity_type, :entity_id)

    document.body.scan(ContentFormatterService::TOKEN_REGEX).each do |entity_type, id|
      unless current_entities.include?([entity_type, id.to_i])
        # Unfortunately, we need to hit the DB again to fetch the page to ensure it's owned
        # by the document owner, or else people could add arbitrary pages to quick reference
        # to view them.
        next unless Rails.application.config.content_types[:all].map(&:name).include?(entity_type)
        related_page = entity_type.constantize.find(id)
        # todo we could also work off privacy here, so people could add public pages to quick ference
        # -- we'd have to delete those quick-references whenever a page went private though
        next unless related_page.user_id == document.user_id

        analysis.document_entities.create(
          entity_type:          entity_type,
          entity_id:            id.to_i,
          document_analysis_id: analysis.id
        )

        current_entities << [entity_type, id.to_i]
      end
    end
  end
end

# Release note (8/2/19):
# We could pretty easily kick off a DocumentMentionJob for every document in the system
# to start everyone off. We probably want to wait for a window after release to monitor
# page speeds once people start linking quick reference pages, but if all looks well lets
# do it.