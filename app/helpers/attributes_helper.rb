module AttributesHelper
  def attribute_category_tab(content, category)
    is_disabled = category.attribute_fields.any? do |field|
      if content.respond_to?(field.name.to_sym)
        content.send(field.name).present?
      else
        field.attribute_values.where(entity: content).any?
      end
    end

    link = content_tag(:a, category.label, href: "##{category.name.gsub("'", '')}_panel")
    content_tag(:li, link, class: "tab col s3 #{is_disabled}")
  end
end
