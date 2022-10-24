module MarketingHelper
  def linked_page_type(text:, page_type:)
    content_tag(:a, href: send("#{page_type.name.downcase}_worldbuilding_info_path"), class: page_type.text_color) do
      content_tag(:strong, text)
    end
  end
end
