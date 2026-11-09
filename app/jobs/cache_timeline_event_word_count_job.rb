class CacheTimelineEventWordCountJob < ApplicationJob
  queue_as :cache

  # previous_word_count / edited_word_count: the event's counts before and after the edit (see
  # TimelineEvent#enqueue_word_count_update). The day's row records the count after the edit, and
  # if this job creates that row, the day starts from the count before it.
  def perform(timeline_event_id, previous_word_count = nil, edited_word_count = nil)
    timeline_event = TimelineEvent.find_by(id: timeline_event_id)
    return if timeline_event.nil?

    total_word_count = TimelineEvent.word_count_of(timeline_event.title, timeline_event.description)
    cached_before = timeline_event.cached_word_count

    # Cache the total word count on the model
    timeline_event.update_column(:cached_word_count, total_word_count) unless cached_before == total_word_count

    # Get user via timeline association
    user = timeline_event.timeline&.user
    return if user.nil?

    # The day the edit was made (when this job was queued, not when it runs), in the writer's time zone
    date = WordCountUpdate.date_for(user, enqueued_at || Time.current)
    WordCountUpdate.record!(timeline_event, date: date, word_count: edited_word_count || total_word_count, user_id: user.id) do
      previous_word_count || cached_before
    end
  end
end
