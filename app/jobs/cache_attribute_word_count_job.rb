class CacheAttributeWordCountJob < ApplicationJob
  queue_as :cache

  def perform(*args)
    attribute_id = args.shift
    attribute    = Attribute.includes(:attribute_field).find_by(id: attribute_id)

    # If the attribute has been deleted since this job was enqueued, just bail
    if attribute.nil?
      return
    end

    # If we have a blank/null value, ezpz 0 words
    if attribute.value.nil? || attribute.value.blank?
      attribute.update_column(:word_count_cache, 0)
      return
    end

    # Skip word counting for non-prose field types (links store JSON, not text)
    field_type = attribute.attribute_field&.field_type
    if %w[link universe tags].include?(field_type)
      attribute.update_column(:word_count_cache, 0)
      return
    end

    # Use centralized WordCountService for consistent counting across the app
    word_count = WordCountService.count(attribute.value)

    attribute.update_column(:word_count_cache, word_count)
  end
end
