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
end
