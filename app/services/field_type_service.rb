class FieldTypeService < Service
  def self.form_path(field)
    case field[:type]
    when 'text_area'
      Rails.application.routes.url_helpers.text_field_update_path(field[:internal_id])
    when 'name'
      Rails.application.routes.url_helpers.name_field_update_path(field[:internal_id])
    when 'universe'
      Rails.application.routes.url_helpers.universe_field_update_path(field[:internal_id])
    when 'tags'
      Rails.application.routes.url_helpers.tags_field_update_path(field[:internal_id])
    when 'link'
      Rails.application.routes.url_helpers.link_field_update_path(field[:internal_id])
    else
      raise "Unexpected/unhandled field type: #{field[:type]}"
    end
  end

  def self.form_path_from_attribute_field(field)
    field_data = {
      type: field.field_type,
      internal_id: field.id
    }

    form_path(field_data)
  end
end
