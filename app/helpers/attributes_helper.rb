module AttributesHelper
  #todo this might not actually be used anymore
  def attribute_category_tab(content, category)
    is_disabled = category.attribute_fields.any? do |field|
      if content.respond_to?(field.name.to_sym)
        content.send(field.name).present?
      else
        field.attribute_values.where(entity: content).any?
      end
    end

    link = content_tag(:a, category.label, href: "##{category.name.gsub("'", '')}_panel")
    # todo: revisit logic for is_disabled -- doesn't disable empty tabs
    content_tag(:li, link, class: "tab #{'disabled' if false}")
  end
  
  # Helper method to resolve linkable content types for link fields
  def get_linkable_content_types(linkable_types_array)
    return [] if linkable_types_array.blank?
    
    # Get all available content types
    all_content_types = Rails.application.config.content_types[:all]
    
    # Filter to only include the types that are linkable for this field
    all_content_types.select do |content_type|
      linkable_types_array.include?(content_type.name)
    end.compact
  rescue => e
    # Graceful degradation if there are any issues resolving content types
    Rails.logger.warn "Error resolving linkable content types: #{e.message}"
    []
  end
end
