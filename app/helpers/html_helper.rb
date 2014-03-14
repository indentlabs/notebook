module HtmlHelper
  def generate_picker_code_for(content_array, glyphicon_id)
    return if content_array.length == 0
    [
      '<div class="input-group-btn">',
        '<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">',
          '<span class="glyphicon glyphicon-'+glyphicon_id+'"></span>',
          '<span class="caret"></span>',
        '</button>',
        '<ul class="dropdown-menu">',
          content_array.map { |content|
            '<li><a href="#">' + content.name + '</a></li>'
          },
        '</ul>',
      '</div>'
    ].join("\n").html_safe
  end

  def character_picker
    characters = Character.where(user_id: session[:user])
    generate_picker_code_for(characters, 'user')
  end
  
  def universe_picker
    universes = Universe.where(user_id: session[:user])
    generate_picker_code_for(universes, 'globe')
  end
  
  def equipment_picker
    equipment = Equipment.where(user_id: session[:user])
    generate_picker_code_for(equipment, 'gift')
  end
  
  def language_picker
    languages = Language.where(user_id: session[:user])
    generate_picker_code_for(languages, 'comment')
  end
  
  def location_picker
    locations = Location.where(user_id: session[:user])
    generate_picker_code_for(locations, 'road')
  end
  
end
