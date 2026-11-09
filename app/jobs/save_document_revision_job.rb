# Runs at the end of each debounce window after a document is saved (see Document#enqueue_debounced)
# and records the document's word count for the day. (Despite the name, revisions are kept when the
# document is saved; see Document#keep_replaced_version! The name stays until queued jobs drain.)
class SaveDocumentRevisionJob < ApplicationJob
  queue_as :low_priority

  def perform(document_id)
    document = Document.find_by(id: document_id)
    return unless document

    # Always count on the server: the editor's count is only for display, and an editor tab left
    # open since before a change to the counter would send counts made the old way.
    word_count = WordCountService.count(document.body)
    document.update_column(:cached_word_count, word_count) unless document.cached_word_count == word_count

    record_word_count(document, word_count) if document.user_id
  end

  private

  def record_word_count(document, word_count)
    # The day the edit was made (when this job was queued, not when it runs), in the writer's time zone
    date = WordCountUpdate.date_for(document.user, enqueued_at || Time.current)

    # If writing has already started on a later day (this job's window ran past midnight), that day
    # started from the text as it was at the end of this one, so record that rather than counting
    # the later day's words on both days...
    later_rows = document.word_count_updates.where('for_date > ?', date).where.not(starting_word_count: nil).order(:for_date).to_a
    day_count = later_rows.first&.starting_word_count || word_count

    # A row written before starting counts were recorded keeps what it has credited so far
    existing = document.word_count_updates.find_by(for_date: date)
    existing.convert_to_starting_count!(day_count) if existing && existing.starting_word_count.nil?

    # If this job creates the day's row, the body hasn't changed that day (the first body change
    # creates the row; see Document#record_starting_word_count!), so the day starts from its count.
    WordCountUpdate.record!(document, date: date, word_count: day_count) { day_count }

    # ...and give the text as it is now to the newest day: a save just after midnight inside this
    # job's debounce window queued no job of its own, so this is the only job that will see it.
    later_rows.last&.update!(word_count: word_count)
  end
end
