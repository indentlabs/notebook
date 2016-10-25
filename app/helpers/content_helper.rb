module ContentHelper
  def new_content_button(content)
    icon = content_tag(:i, content.icon, class: "material-icons #{content.color}-text")
    link = link_to("+ #{icon}".html_safe, new_polymorphic_path(content.build), class: "btn white #{content.color}-text")

    content_tag(:small, link, class: 'right')
  end

  def content_settings_button(content)
    icon = content_tag(:i, 'chrome_reader_mode', class: "material-icons #{content.color}-text")
    link = link_to("+ #{icon}".html_safe, new_attribute_category_for_entity_path(content.content_name), class: "btn white #{content.color}-text")

    content_tag(:small, link, class: 'right')
  end
end
