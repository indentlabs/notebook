# Helps generate HTML constructs for object owned by the user
module ApplicationHelper
  # Will output a link to the item if it exists and is owned by the
  # current logged-in user. Otherwise will just print a text title
  def link_if_present(name, type)
    return name unless session[:user]
    userid = User.where(id: session[:user]).first.id

    type = type.downcase
    result = find_by_name_and_type name, type, userid

    result.nil? ? name : link_to(name, result)
  end

  def find_by_name_and_type(name, type, userid)
    model = find_model_by_type type

    model.where(name: name, user_id: userid).first unless model.nil?
  end

  def find_model_by_type(type) # rubocop:disable Style/CyclomaticComplexity
    case type
    when 'character' then return Character
    when 'equipment' then return Equipment
    when 'language' then return Language
    when 'location' then return Location
    when 'magic' then return Magic
    when 'universe' then return Universe
    end
  end

  def print_property(title, value, type = '')
    return unless value && value.length > 0

    [
      '<dt><strong>', title, ':</strong></dt>',
      '<dd>', simple_format(link_if_present(value, type)), '</dd>'
    ].join('').to_s.html_safe
  end
end
