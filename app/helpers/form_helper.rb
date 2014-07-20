module FormHelper
  def generate_form_row_for(form_handler, field, label_override = nil, toolbox = {})
    label = label_override.nil? ? field : label_override
    [
      '<div class="row">',
        '<div class="col-xs-2" style="text-align: right;">',
          form_handler.label(label, :class => 'control-label'),
        '</div>',
        '<div class="col-xs-9">',
          form_handler.text_field(field, :class => 'form-control'),
        '</div>',
        '<div class="col-xs-1">',
          toolbox.map { |button|
            "<a href='#' class='btn #{button[:action]}'>" +
              "<span class='glyphicon glyphicon-#{button[:icon]}'></span>" +
            '</a>'
          },
        '</div>',
      '</div>'
    ].join("\n").html_safe
  end


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
