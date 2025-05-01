class SaveDocumentRevisionJob < ApplicationJob
  queue_as :low_priority

  def perform(*args)
    document_id = args.shift

    document = Document.find_by(id: document_id)
    return unless document

    # Load body once (needed for potential fallback and revision)
    body_text = document.body || ""
    new_word_count = 0

    begin
      # Try the accurate (but potentially memory-intensive) count first
      new_word_count = document.computed_word_count # Let it load body internally
    rescue StandardError => e
      # Log the error for visibility
      Rails.logger.warn("SaveDocumentRevisionJob: Failed accurate word count for Document #{document_id}: #{e.message}. Falling back to basic count.")
      # Fallback to basic count if accurate one fails (e.g., NoMemoryError or other issues)
      new_word_count = body_text.split.size
    end

    # Update cached word count for the document
    document.update(cached_word_count: new_word_count)

    # Save a WordCountUpdate for this document for today
    update = document.word_count_updates.find_or_initialize_by(
      for_date: DateTime.current,
    )
    update.word_count = new_word_count
    update.user_id  ||= document.user_id
    update.save!

    # Make sure we're only storing revisions at least every 5 min
    latest_revision = document.document_revisions.order('created_at DESC').limit(1).first
    if latest_revision.present? && latest_revision.created_at > 5.minutes.ago
      return
    end

    # Store the document information as-is
    document.document_revisions.create!(
      title:             document.title,
      body:              body_text, # Use the body_text we already loaded
      synopsis:          document.synopsis,
      universe_id:       document.universe_id,
      notes_text:        document.notes_text,
      cached_word_count: new_word_count
    )
  end
end