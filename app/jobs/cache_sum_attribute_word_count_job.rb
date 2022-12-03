class CacheSumAttributeWordCountJob < ApplicationJob
  queue_as :cache

  def perform(*args)
    entity_type = args.shift
    entity_id   = args.shift

    entity = entity_type.constantize.find_by(id: entity_id)
    return if entity.nil?

    save_daily_word_count_changes(entity)
  end

  def save_daily_word_count_changes(entity)
    # Grab the latest total word count for this entity
    sum_attribute_word_count = Attribute.where(entity_type: entity.class.name, entity_id: entity.id).sum(:word_count_cache)

    # Cache the total word count onto the model, too
    entity.update(cached_word_count: sum_attribute_word_count)

    # Create or re-use an existing WordCountUpdate for today
    update = entity.word_count_updates.find_or_initialize_by(
      for_date: DateTime.current,
    )
    update.word_count = sum_attribute_word_count
    update.user_id  ||= entity.user_id

    # Save!
    update.save!
  end
end
