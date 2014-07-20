module FormHelper
  def generate_form_row_for(form_handler, field, label_override = nil, toolbox = {})
    label = (label_override.nil? ? field : label_override.titleize)
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

end
