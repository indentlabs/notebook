module HtmlHelper
  def picker_from_type(content_type)
    case content_type
    when 'character'
      character_picker
    when 'universe'
      universe_picker
    when 'equipment'
      equipment_picker
    when 'language'
      language_picker
    when 'location'
      location_picker
    end
  end

  def generate_picker_code_for(content_array, glyphicon_id)
    return if content_array.length == 0
    [
      '<span class="dropdown-picker">',
        '<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">',
          '<span class="glyphicon glyphicon-'+glyphicon_id+'"></span>',
          '<span class="caret"></span>',
        '</button>',
        '<ul class="dropdown-menu">',
          content_array.map { |content|
            '<li><a href="#">' + content.name + '</a></li>'
          },
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
