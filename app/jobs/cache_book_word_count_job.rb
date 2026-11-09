class CacheBookWordCountJob < ApplicationJob
  queue_as :cache

  # previous_word_count / edited_word_count: the book's counts before and after the edit (see
  # Book#enqueue_word_count_update). The day's row records the count after the edit, and if this
  # job creates that row, the day starts from the count before it.
  def perform(book_id, previous_word_count = nil, edited_word_count = nil)
    book = Book.find_by(id: book_id)
    return if book.nil?

    total_word_count = Book.word_count_of(book.description, book.blurb)
    cached_before = book.cached_word_count

    # Cache the total word count on the model
    book.update_column(:cached_word_count, total_word_count) unless cached_before == total_word_count

    # The day the edit was made (when this job was queued, not when it runs), in the writer's time zone
    date = WordCountUpdate.date_for(book.user, enqueued_at || Time.current)
    WordCountUpdate.record!(book, date: date, word_count: edited_word_count || total_word_count) do
      previous_word_count || cached_before
    end
  end
end
