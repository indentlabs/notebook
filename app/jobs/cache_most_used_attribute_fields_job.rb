class CacheMostUsedAttributeFieldsJob < ApplicationJob
  queue_as :cache

  def perform(*args)
    entity_type    = args.shift
    category_label = args.shift

    puts "Entity type: #{entity_type}"
    puts "Label: #{category_label}"

    category_query = AttributeCategory.where(label: category_label)
    category_query = category_query.where(entity_type: entity_type)
    
    suggestions = AttributeField.where(attribute_category_id: category_query.pluck(:id))
      .group(:label)
      .order('count_id DESC')
      .limit(50)
      .count(:id)
      .reject { |_, count| count < AttributeFieldSuggestion::USAGE_FREQUENCY_MINIMUM }

    puts "Suggestion count: #{suggestions}"

    suggestions.each do |suggestion, weight|
      AttributeFieldSuggestion.find_or_create_by!(
        entity_type:    entity_type,
        category_label: category_label,
        suggestion:     suggestion,
        weight:         weight
      )
    end
  end
end
