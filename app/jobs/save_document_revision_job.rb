# Runs at the end of each debounce window after a document is saved (see Document#enqueue_debounced).
# It records the document's word count for the day and keeps its revision history up to date.
class SaveDocumentRevisionJob < ApplicationJob
  queue_as :low_priority

  # Each revision covers up to this long. While a revision is this new, the job updates it in place
  # with the latest text, so it ends up holding the text as it was at the end of that stretch of
  # writing. A revision that held the start of the stretch instead would make its "Show Changes"
  # show the end of the previous session as written now, and leave the last minutes of every
  # session out of the history until the next session began.
  REVISION_WINDOW = 5.minutes

  # A save that removes this many words, or this share of the document, starts a new revision
  # rather than overwriting the open one, so deleting a chunk by accident can't overwrite the only
  # copy of what was written in this window.
  LARGE_DELETION_WORDS = 100
  LARGE_DELETION_SHARE = 0.25

  def perform(document_id)
    document = Document.find_by(id: document_id)
    return unless document

    body = document.body.to_s

    # Always count on the server: the editor's count is only for display, and an editor tab left
    # open since before a change to the counter would send counts made the old way.
    word_count = WordCountService.count_with_fallback(body)
    document.update_column(:cached_word_count, word_count) unless document.cached_word_count == word_count

    if document.user_id
      # The day the edit was made (when this job was queued, not when it runs), in the writer's time zone
      date = WordCountUpdate.date_for(document.user, enqueued_at || Time.current)
      WordCountUpdate.record!(document, date: date, word_count: word_count)
    end

    save_revision(document, body, word_count)
  end

  private

  def save_revision(document, body, word_count)
    attributes = {
      title:             document.title,
      body:              body,
      synopsis:          document.synopsis,
      universe_id:       document.universe_id,
      notes_text:        document.notes_text,
      cached_word_count: word_count
    }

    latest = document.document_revisions.order(created_at: :desc, id: :desc).first
    if latest && latest.created_at > REVISION_WINDOW.ago && !large_deletion?(latest, word_count)
      latest.update!(attributes) # a no-op when nothing has changed
    else
      document.document_revisions.create!(attributes)
    end
  end

  def large_deletion?(revision, word_count)
    removed = revision.cached_word_count.to_i - word_count
    removed >= LARGE_DELETION_WORDS || (removed > 0 && removed >= revision.cached_word_count.to_i * LARGE_DELETION_SHARE)
  end
end
