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
  # words_changed: how much a field edit changed the page's count. Without it (a field was removed,
  #   or a job queued before this change), only the page's total and an existing day's row change.
  # recount: how much of the total's change is a field being counted afresh rather than writing
  #   (see CacheAttributeWordCountJob). It moves the day's starting count instead of crediting.
  def save_daily_word_count_changes(entity, edited_at: nil, words_changed: nil, recount: 0)
    total = Attribute.where(entity_type: entity.class.name, entity_id: entity.id).sum(:word_count_cache)

    # update_column: validations (a page with no name, say) mustn't stop the count being saved,
    # and the page has already been touched by the edit itself.
    entity.update_column(:cached_word_count, total) unless entity.cached_word_count == total

    date = WordCountUpdate.date_for(entity.user, edited_at || enqueued_at || Time.current)

    if words_changed.nil?
      # Removing a field isn't writing: lower the day's count if the page has one, but don't add a
      # row for every page a deleted template field was on.
      entity.word_count_updates.find_by(for_date: date)&.update!(word_count: total)
      return
    end

    row = WordCountUpdate.record!(entity, date: date, word_count: total) { total - words_changed }
    if recount != 0 && !row.previously_new_record?
      row.update!(starting_word_count: row.starting_count + recount)
    end
    row
  end
end
