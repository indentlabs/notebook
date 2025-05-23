class SaveDocumentRevisionJob < ApplicationJob
  queue_as :low_priority

  def perform(*args)
    document_id = args.shift
    document = Document.find_by(id: document_id)
    return unless document

    # Initialize variables; body is NOT loaded yet
    new_word_count = 0
    body_loaded = false
    body_text = nil

    begin
      # Try the accurate (but potentially memory-intensive) count first
      # This accesses document.body internally
      new_word_count = document.computed_word_count
    rescue StandardError => e
      # Log the error for visibility
      Rails.logger.warn("SaveDocumentRevisionJob: Failed accurate word count for Document #{document_id}: #{e.message}. Falling back to basic count.")

      # Fallback: Load body ONLY if needed for fallback count
      body_text = document.body || "" # Load body here
      body_loaded = true
      new_word_count = body_text.split.size
    end

    # Update cached word count for the document (always do this)
    document.update(cached_word_count: new_word_count)

    # Save a WordCountUpdate for this document for today (always do this)
    update = document.word_count_updates.find_or_initialize_by(
      for_date: DateTime.current,
    )
    update.word_count = new_word_count
    update.user_id  ||= document.user_id
    update.save!

    # Check if revision is needed BEFORE potentially loading body again
    latest_revision = document.document_revisions.order('created_at DESC').limit(1).first
    if latest_revision.present? && latest_revision.created_at > 5.minutes.ago # read as "AFTER" the time which was 5 minutes ago, not "LESS THAN" 5 minutes ago
      # Revision not needed, exit early. Body only loaded if fallback count happened.
      return
    end

    # Revision IS needed. Load body if it wasn't already loaded for the fallback count.
    unless body_loaded
      body_text = document.body || "" # Load body here
      # body_loaded = true # State update no longer needed
    end

    # Store the document information as-is, using the potentially-large body_text
    document.document_revisions.create!(
      title:             document.title,
      body:              body_text, # Use the body_text (now definitely loaded if needed)
      synopsis:          document.synopsis,
      universe_id:       document.universe_id,
      notes_text:        document.notes_text,
      cached_word_count: new_word_count
    )
  end
end