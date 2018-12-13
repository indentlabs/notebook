class ContentSerializer
  attr_accessor :id, :name, :user, :universe

  attr_accessor :categories
  attr_accessor :fields
  attr_accessor :attribute_values

  attr_accessor :raw_model
  attr_accessor :class_name, :class_color, :class_icon

  attr_accessor :data
  # name: 'blah,
  # categories: [
  #  {
  #   name: 'category one',
  #   fields: [{
  #     id: field.name,
  #     label: field.label,
  #     value: field.attribute_values.find_by(..)
  #   }]
  # }

  def initialize(content)
    # One query per table; lets not muck with joins yet
    # self.attribute_values = Attribute.where(entity_type: content.page_type, entity_id: content.id)
    # self.fields           = AttributeField.where(id: self.attribute_values.pluck(:attribute_field_id).uniq)
    self.categories       = content.class.attribute_categories(content.user)
    self.fields           = AttributeField.where(attribute_category_id: self.categories.map(&:id))
    self.attribute_values = Attribute.where(attribute_field_id: self.fields.map(&:id), entity_type: content.page_type, entity_id: content.id)

    self.id               = content.id
    self.name             = content.name
    self.user             = content.user
    self.universe         = content.is_a?(Universe) ? self : content.universe

    self.raw_model        = content

    self.class_name       = content.class.name
    self.class_color      = content.class.color
    self.class_icon       = content.class.icon

    self.data = {
      name: content.try(:name),
      description: content.try(:description),
      universe: self.universe.nil? ? nil : {
        id: self.universe.id,
        name: self.universe.try(:name)
      },
      categories: self.categories.map { |category|
        {
          name:   category.name,
          label:  category.label,
          icon:   category.icon,
          hidden: !!category.hidden,
          fields: self.fields.select { |field| field.attribute_category_id == category.id }.map { |field|
            {
              id:     field.name,
              label:  field.label,
              type:   field.field_type,
              hidden: !!field.hidden,
              old_column_source: field.old_column_source,
              value: self.attribute_values.detect { |value|
                value.entity_type == content.page_type &&
                value.entity_id   == content.id &&
                value.attribute_field_id == field.id
              }.try(:value) || ""
            }
          }.sort do |a, b|
            a_value = case a[:type]
              when 'name'     then 0
              when 'universe' then 1
              else 2 # 'text_area', 'link'
            end

            b_value = case b[:type]
              when 'name'     then 0
              when 'universe' then 1
              else 2
            end

            # if a_value != b_value
            #   a_value <=> b_value
            # else
            #   a[:label] <=> b[:label]
            # end

            a_value <=> b_value
          end
        }
      }
    }
  end
end
