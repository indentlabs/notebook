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
end
