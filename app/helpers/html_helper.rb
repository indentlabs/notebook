# Helps generate small HTML constructs
module HtmlHelper
  PICKER_ICONS = {
    'character' => 'user',
    'universe' => 'globe',
    'equipment' => 'gift',
    'language' => 'comment',
    'location' => 'road'
  }

  def picker_for(content_type)
    content_array = send "my_#{content_type.pluralize}"
    generate_picker_code_for(content_array, PICKER_ICONS[content_type])
  rescue
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
end
