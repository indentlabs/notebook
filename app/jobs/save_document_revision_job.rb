class SaveDocumentRevisionJob < ApplicationJob
  queue_as :low_priority

  def perform(*args)
    document_id = args.shift

    document = Document.find(document_id)
    return unless document.present?

    # Update cached word count for the document regardless of how often this is called
    new_word_count = document.computed_word_count
    document.update(cached_word_count: new_word_count)

    # Make sure we're only storing revisions at least every 5 min
    latest_revision = document.document_revisions.order('created_at DESC').limit(1).first
    if latest_revision.present? && latest_revision.created_at > 5.minutes.ago
      return
    end

    # Store the document information as-is
    document.document_revisions.create!(
      title:             document.title,
      body:              document.body,
      synopsis:          document.synopsis,
      universe_id:       document.universe_id,
      notes_text:        document.notes_text,
      cached_word_count: new_word_count
    )
  end
end