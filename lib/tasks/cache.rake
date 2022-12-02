namespace :cache do
  desc "Cache a random selection of attribute category suggestions"
  task attribute_category_suggestions: :environment do
    Rails.application.config.content_types[:all].each do |content_type|
      puts "Caching random attribute category suggestions for #{content_type.name}"

      random_categories = AttributeCategory.where(entity_type: content_type.name.downcase)
        .pluck(:label)
        .uniq
        .sample(10)

      random_categories.each do |category|
        puts "\tCategory: #{category}"
        CacheMostUsedAttributeCategoriesJob.perform_later(
          content_type.name.downcase,
        )
      end
    end
  end

  desc "Cache a random selection of attribute field suggestions"
  task attribute_field_suggestions: :environment do
    Rails.application.config.content_types[:all].each do |content_type|
      puts "Caching random attribute field suggestions for #{content_type.name}"

      random_categories = AttributeCategory.where(entity_type: content_type.name.downcase)
        .pluck(:label)
        .uniq
        .sample(10)

      random_categories.each do |category|
        puts "\tCategory: #{category}"
        CacheMostUsedAttributeFieldsJob.perform_later(
          content_type.name.downcase,
          category
        )
      end
    end
  end

  desc "Recompute ALL attribute word count caches"
  task recompute_all_attribute_word_counts: :environment do
    Attribute.find_each do |attribute|
      begin
        CacheAttributeWordCountJob.perform_now(attribute.id)

      rescue ActiveRecord::RecordInvalid => e
        puts "Something died for attribute ID=#{attribute.id} (#{attribute.entity_type} #{attribute.entity_id}) but we're carrying on."
        puts e.inspect
      end
    end
  end

  desc "Recompute ALL page word count caches"
  task recompute_all_page_word_counts: :environment do
    Rails.application.config.content_types[:all].each do |content_type|
      puts "Recomputing #{content_type.name} word counts"

      content_type.order('updated_at DESC').find_each do |entity|
        sum_attribute_word_count = Attribute.where(entity_type: content_type.name, entity_id: entity.id).sum(:word_count_cache)
        entity.update(cached_word_count: sum_attribute_word_count)
      end
    end
  end
end
