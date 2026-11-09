# Runs at the end of each debounce window after a document is saved (see Document#enqueue_debounced).
# It records the document's word count for the day and keeps its revision history up to date.
class SaveDocumentRevisionJob < ApplicationJob
  queue_as :low_priority

  # Each revision covers up to this long. While a revision is this new (and not closed), the job
  # updates it in place with the latest text, so it ends up holding the text as it was at the end of
  # that stretch of writing. A revision that held the start of the stretch instead would make its
  # "Show Changes" show the end of the previous session as written now, and leave the last minutes
  # of every session out of the history until the next session began.
  REVISION_WINDOW = 5.minutes

  # A save that removes this many words of the open revision's text, or this share of it, starts a
  # new revision instead of overwriting the open one, so text that was deleted, pasted over or
  # overwritten from a stale tab stays in the history.
  LARGE_DELETION_WORDS = 50
  LARGE_DELETION_SHARE = 0.25

  def perform(document_id)
    document = Document.find_by(id: document_id)
    return unless document

    body = document.body.to_s

    # Always count on the server: the editor's count is only for display, and an editor tab left
    # open since before a change to the counter would send counts made the old way.
    word_count = WordCountService.count_with_fallback(body)
    document.update_column(:cached_word_count, word_count) unless document.cached_word_count == word_count

    record_word_count(document, word_count) if document.user_id
    save_revision(document, body, word_count)
  end

  private

  def record_word_count(document, word_count)
    # The day the edit was made (when this job was queued, not when it runs), in the writer's time zone
    date = WordCountUpdate.date_for(document.user, enqueued_at || Time.current)

    # If writing has already started on a later day (this job ran late, past midnight), that day
    # started from the text as it was at the end of this one, so record that rather than counting
    # the later day's words on both days.
    later_start = document.word_count_updates
      .where('for_date > ?', date)
      .where.not(starting_word_count: nil)
      .order(:for_date)
      .pick(:starting_word_count)
    day_count = later_start || word_count

    # A row written before starting counts were recorded keeps what it has credited so far
    existing = document.word_count_updates.find_by(for_date: date)
    existing.convert_to_starting_count!(day_count) if existing && existing.starting_word_count.nil?

    # If this job creates the day's row, the body hasn't changed that day (the first body change
    # creates the row; see Document#record_starting_word_count!), so the day starts from its count.
    WordCountUpdate.record!(document, date: date, word_count: day_count) { day_count }
  end

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
    if latest && open?(latest) && !large_deletion?(latest, body)
      latest.update!(attributes) # a no-op when nothing has changed
    else
      # Nothing older may be changed again, even if a newer revision is deleted later
      document.document_revisions.where(closed_at: nil).update_all(closed_at: Time.current)
      document.document_revisions.create!(attributes)
    end
  end

  def open?(revision)
    revision.closed_at.nil? && revision.created_at > REVISION_WINDOW.ago
  end

  # Measures the words that are in the open revision but no longer in the document: what lies
  # between the text the two share at the start and at the end.
  def large_deletion?(revision, body)
    old_body = revision.body.to_s
    return false if old_body == body

    prefix = common_prefix_bytes(old_body, body)
    suffix = common_suffix_bytes(old_body, body, [old_body.bytesize, body.bytesize].min - prefix)
    removed_text = old_body.byteslice(prefix, old_body.bytesize - prefix - suffix).scrub('')
    removed = WordCountService.count(removed_text)

    removed >= LARGE_DELETION_WORDS || (removed > 0 && removed >= revision.cached_word_count.to_i * LARGE_DELETION_SHARE)
  end

  # Binary search with whole-slice comparisons, which run in C, rather than a character-by-character loop
  def common_prefix_bytes(a, b)
    low = 0
    high = [a.bytesize, b.bytesize].min
    while low < high
      mid = (low + high + 1) / 2
      a.byteslice(0, mid) == b.byteslice(0, mid) ? low = mid : high = mid - 1
    end
    low
  end

  def common_suffix_bytes(a, b, limit)
    low = 0
    high = limit
    while low < high
      mid = (low + high + 1) / 2
      a.byteslice(a.bytesize - mid, mid) == b.byteslice(b.bytesize - mid, mid) ? low = mid : high = mid - 1
    end
    low
  end
end
