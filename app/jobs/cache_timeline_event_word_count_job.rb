class CacheTimelineEventWordCountJob < ApplicationJob
  queue_as :cache

  MAX_RETRY_ATTEMPTS = 3

  def perform(timeline_event_id)
    timeline_event = TimelineEvent.find_by(id: timeline_event_id)
    return if timeline_event.nil?

    # Count words in title and description
    title_words = timeline_event.title.present? ? WordCountService.count_with_fallback(timeline_event.title) : 0
    description_words = timeline_event.description.present? ? WordCountService.count_with_fallback(timeline_event.description) : 0
    total_word_count = title_words + description_words

    # Cache the total word count on the model
    timeline_event.update_column(:cached_word_count, total_word_count)

    # Get user via timeline association
    user = timeline_event.timeline&.user
    return if user.nil?

    # Determine the user's date based on their timezone at enqueue time (not job execution time)
    enqueue_time = enqueued_at || Time.current
    user_date = user.time_zone.present? ? enqueue_time.in_time_zone(user.time_zone).to_date : enqueue_time.to_date

    # Create or update WordCountUpdate for today (in user's timezone)
    retry_count = 0
    begin
      update = timeline_event.word_count_updates.find_or_initialize_by(for_date: user_date)
      update.word_count = total_word_count
      update.user_id ||= user.id
      update.save!
    rescue ActiveRecord::RecordNotUnique
      retry_count += 1
      if retry_count <= MAX_RETRY_ATTEMPTS
        retry
      else
        Rails.logger.error("CacheTimelineEventWordCountJob: max retries exceeded for TimelineEvent##{timeline_event_id} on #{user_date}")
        raise # Let Sidekiq handle with its retry mechanism
      end
    end
  end
end
