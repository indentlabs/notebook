class CacheSumAttributeWordCountJob < ApplicationJob
  queue_as :cache

  def perform(*args)
    entity_type = args.shift
    entity_id   = args.shift

    entity = entity_type.constantize.find_by(id: entity_id)
    return if entity.nil?

    sum_attribute_word_count = Attribute.where(entity_type: entity_type, entity_id: entity_id).sum(:word_count_cache)
    update = entity.word_count_updates.find_or_initialize_by(
      for_date: DateTime.current,
    )
    update.word_count = sum_attribute_word_count
    update.user_id  ||= entity.user_id

    update.save!
  end
end
