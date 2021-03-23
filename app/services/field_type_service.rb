class FieldTypeService < Service
  def self.form_path(field)
    case field[:type]
    when 'text_area'
      Rails.application.routes.url_helpers.attribute_field_path(field[:internal_id])
    when 'name'
      Rails.application.routes.url_helpers.attribute_field_path(field[:internal_id])
    when 'universe'
      Rails.application.routes.url_helpers.attribute_field_path(field[:internal_id])
    when 'tag'
      Rails.application.routes.url_helpers.attribute_field_path(field[:internal_id])
    when 'link'
      Rails.application.routes.url_helpers.link_field_update_path(field[:internal_id])
    end
  end
end