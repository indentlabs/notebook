# This is an implementation of ContentSerializer that only exposes public columns in the 
# standard API format and should be preferred when possible.

class ApiContentSerializer
  attr_accessor :id, :name, :user, :universe

  attr_accessor :categories
  attr_accessor :fields
  attr_accessor :attribute_values
  attr_accessor :page_tags
  attr_accessor :documents

  attr_accessor :raw_model
  attr_accessor :class_name, :class_color, :class_icon

  attr_accessor :data

  def initialize(content, include_blank_fields: false)
    self.categories       = content.class.attribute_categories(content.user).where(hidden: [false, nil]).eager_load(attribute_fields: :attribute_values)
    self.fields           = AttributeField.where(attribute_category_id: self.categories.map(&:id), hidden: [false, nil])
    self.attribute_values = Attribute.where(attribute_field_id: self.fields.map(&:id), entity_type: content.page_type, entity_id: content.id).order('created_at desc')
    self.universe         = (content.class.name == Universe.name) ? nil : content.universe

    self.raw_model        = content

    self.page_tags        = content.page_tags.select(:id, :tag, :slug) || []
    self.documents        = content.documents             || []

    self.data = {
      name:        content.try(:name),
      description: content.try(:description),
      universe:    self.universe.nil? ? nil : {
        id:   self.universe.id,
        name: self.universe.try(:name)
      },
      meta: {
        created_at: content.created_at,
        updated_at: content.updated_at
      },
      categories: self.categories.map { |category|
        {
          id:     category.id,
          label:  category.label,
          icon:   category.icon,
          fields: category.attribute_fields.order(:position).map { |field|
            {
              id:     field.id,
              label:  field.label,
              type:   field.field_type,
              value:  value_for(field, content)
            }
          }.reject { |field| !include_blank_fields && field[:value].empty? }
        }
      }.reject { |category| !include_blank_fields && category[:fields].empty? },
      references: []
    }
  end

  def value_for(attribute_field, content)
    case attribute_field.field_type
    when 'link'
      # code smell: why aren't we handling new-style links here?
      self.raw_model.send(attribute_field.old_column_source)

    when 'tags'
      self.page_tags

    else # text_area, name, universe, etc
      self.attribute_values.detect { |value| 
        value.entity_type        == content.page_type &&
        value.entity_id          == content.id &&
        value.attribute_field_id == attribute_field.id
      }.try(:value) || ""
    end
  end
end
