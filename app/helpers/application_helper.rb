# Helps generate HTML constructs for object owned by the user
module ApplicationHelper
  # Will output a link to the item if it exists and is owned by the
  # current logged-in user. Otherwise will just print a text title
  def link_if_present(name, type)
    return name unless session[:user]
    result = find_by_name_and_type name, type.downcase, current_user.id

    result.nil? ? name : link_to(name, result)
  end

  def find_by_name_and_type(name, type, userid)
    model = type.titleize.constantize unless type.blank?
    model.where(name: name, user_id: userid).first unless model.nil?
  end

  def print_property(title, value, type = '')
    return unless value.present?

    [
      '<dt><strong>', title, ':</strong></dt>',
      '<dd>', simple_format(link_if_present(value, type)), '</dd>'
    ].join('').to_s.html_safe
  end

  def title(*parts)
    content_for(:title) { (parts << 'Notebook').join(' - ') } unless parts.empty?
  end

  def clean_links(html)
    return '' if html.nil?

    html.gsub!(/\<a href=["'](.*?)["']\>(.*?)\<\/a\>/mi, '<a href="\1" rel="nofollow">\2</a>')
    html.html_safe
  end
end
