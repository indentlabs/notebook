module AttributesHelper
  def attribute_category_tab(content, category)
    is_disabled = category.attribute_fields.map(&:name).any? { |m| content.respond_to?(m) && content.send(m).present? }

    is_disabled = false
    link = content_tag(:a, category.label, href: "##{category.name}_panel")
    list_item = content_tag(:li, link, class: "tab col s3 #{is_disabled}")
  end
end
