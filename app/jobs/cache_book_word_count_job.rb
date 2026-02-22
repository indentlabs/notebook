class CacheBookWordCountJob < ApplicationJob
  queue_as :cache

  MAX_RETRY_ATTEMPTS = 3

  def perform(book_id)
    book = Book.find_by(id: book_id)
    return if book.nil?

    # Count words in description and blurb
    description_words = book.description.present? ? WordCountService.count(book.description) : 0
    blurb_words = book.blurb.present? ? WordCountService.count(book.blurb) : 0
    total_word_count = description_words + blurb_words

    # Cache the total word count on the model
    book.update_column(:cached_word_count, total_word_count)

    # Determine the user's current date based on their timezone
    user = book.user
    user_date = user&.time_zone.present? ? Time.current.in_time_zone(user.time_zone).to_date : Date.current

    # Create or update WordCountUpdate for today (in user's timezone)
    retry_count = 0
    begin
      update = book.word_count_updates.find_or_initialize_by(for_date: user_date)
      update.word_count = total_word_count
      update.user_id ||= book.user_id
      update.save!
    rescue ActiveRecord::RecordNotUnique
      retry_count += 1
      if retry_count <= MAX_RETRY_ATTEMPTS
        retry
      else
        Rails.logger.error("CacheBookWordCountJob: max retries exceeded for Book##{book_id} on #{user_date}")
        raise # Let Sidekiq handle with its retry mechanism
      end
    end
  end
end
