# Helps generate HTML constructs for object owned by the user
module ApplicationHelper
  def content_class_from_name(class_name)
    # If we pass in a class (e.g. Character instead of "Character") by mistake, just return it
    return class_name if class_name.is_a?(Class)

    # Extra whitelisting for some other classes we don't necessarily want in the content_types array
    return Folder if class_name == Folder.name

    Rails.application.config.content_types_by_name[class_name]
  end

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

  def show_notice?(id: nil)
    user_signed_in? && current_user.notice_dismissals.where(notice_id: id).none?
  end

  # Abbreviates large counts (e.g. 1190921 => "1.19M") so stat displays keep
  # a predictable width; counts under 10,000 keep their full delimited form.
  def compact_number(number)
    number = number.to_i
    return number_with_delimiter(number) if number < 10_000

    number_to_human(number,
                    format: '%n%u',
                    precision: 3,
                    significant: true,
                    round_mode: :down,
                    units: { thousand: 'K', million: 'M', billion: 'B', trillion: 'T' })
  end

  def unread_inbox_count
    return 0 unless user_signed_in?
    
    @unread_inbox_count ||= begin
      Thredded::PrivateTopic
        .for_user(current_user)
        .unread(current_user)
        .count
    rescue
      0
    end
  end
end
