class CacheMostUsedAttributeCategoriesJob < ApplicationJob
  queue_as :cache

  def perform(*args)
    entity_type    = args.shift
    puts "Entity type: #{entity_type}"

    suggestions = AttributeCategory.where(entity_type: entity_type)
      .group(:label)
      .order('count_id DESC')
      .limit(50)
      .count(:id)
      .reject { |_, count| count < AttributeCategorySuggestion::USAGE_FREQUENCY_MINIMUM }

    puts "Suggestion count: #{suggestions}"

    suggestions.each do |suggestion, weight|
      suggestion = AttributeCategorySuggestion.find_or_create_by!(
        entity_type:    entity_type,
        suggestion:     suggestion
      )
      suggestion.weight = weight
      suggestion.save!
    end
  end
end
