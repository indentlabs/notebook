# Helps generate small HTML constructs
module HtmlHelper
  def picker_for(content_type)
    picker = "#{content_type}_picker"
    send(picker) if respond_to? picker
  end

  def generate_picker_code_for(content_array, glyphicon_id)
    return if content_array.length == 0
    [
      '<span class="dropdown-picker">',
      '<button type="button" class="btn btn-default dropdown-toggle" \
       data-toggle="dropdown">',
      '<span class="glyphicon glyphicon-' + glyphicon_id + '"></span>',
      '<span class="caret"></span>',
      '</button>',
      '<ul class="dropdown-menu">',
      content_array.map do |content|
        '<li><a href="#">' + content.name + '</a></li>'
      end,
      '</ul>',
      '</span>'
    ].join("\n").html_safe
  end

  def character_picker
    generate_picker_code_for(my_characters, 'user')
  end

  def universe_picker
    generate_picker_code_for(my_universes, 'globe')
  end

  def equipment_picker
    generate_picker_code_for(my_equipment, 'gift')
  end

  def language_picker
    generate_picker_code_for(my_languages, 'comment')
  end

  def location_picker
    generate_picker_code_for(my_locations, 'road')
  end
end
