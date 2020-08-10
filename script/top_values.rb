page_type = Vehicle
field = 'Type of vehicle'

cats = AttributeCategory.where(entity_type: page_type.name.downcase, label: 'Overview').pluck(:id)
fs   = AttributeField.where(attribute_category_id: cats, label: field).pluck(:id)

Attribute.where(attribute_field_id: fs).where.not(value: [nil, ""]).group(:value).order('count_id DESC').limit(100).count(:id).keys.map { |k| k.downcase.strip }.sort
