# Recounts a notebook page's total from its fields' cached counts and records it for the day.
# Usually run straight after CacheAttributeWordCountJob; queued on its own when a field is deleted.
class CacheSumAttributeWordCountJob < ApplicationJob
  queue_as :cache

  def perform(entity_type, entity_id)
    entity = entity_type.safe_constantize&.find_by(id: entity_id)
    return if entity.nil?

    save_daily_word_count_changes(entity)
  end

  # edited_at: when the edit was made, which decides the day it counts towards (in the writer's
  #   time zone). Defaults to when this job was queued.
  # words_changed: how much the edit changed the page's count, when known. The day's first edit
  #   then starts the day from the total minus that change.
  def save_daily_word_count_changes(entity, edited_at: nil, words_changed: nil)
    total = Attribute.where(entity_type: entity.class.name, entity_id: entity.id).sum(:word_count_cache)
    previous_total = entity.cached_word_count

    # update_column: validations (a page with no name, say) mustn't stop the count being saved,
    # and the page has already been touched by the edit itself.
    entity.update_column(:cached_word_count, total) unless previous_total == total

    date = WordCountUpdate.date_for(entity.user, edited_at || enqueued_at || Time.current)
    WordCountUpdate.record!(entity, date: date, word_count: total) do
      if words_changed
        total - words_changed
      else
        # A field was removed, or the edit isn't known: the day starts from the last total, so the
        # removal doesn't count as writing. A page whose total was never cached credits nothing.
        previous_total.to_i > 0 ? previous_total : total
      end
    end
  end
end
