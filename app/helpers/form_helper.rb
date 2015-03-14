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
          toolbox.map { |config| toolbox_button_for(config) },
        '</div>',
      '</div>'
    ].join("\n").html_safe
  end

  def toolbox_button_for(config = {})
    if config[:action].ends_with? '_picker'
      picker_type = config[:action].split('_picker').first
      picker_from_type picker_type
    else
      [
        "<button type='button' class='btn btn-default #{config[:action]}'>",
          "<span class='glyphicon glyphicon-#{config[:icon]}'></span>",
        "</button>"
      ].join("\n").html_safe
    end
  end

end
