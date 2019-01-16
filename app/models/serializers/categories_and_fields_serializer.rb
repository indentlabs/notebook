class CategoriesAndFieldsSerializer
  attr_accessor :data
  attr_accessor :categories, :fields

  attr_accessor :class_name

  def initialize(categories)
    self.categories = categories
    self.fields     = AttributeField.where(attribute_category_id: categories.pluck(:id))

    self.class_name = self.categories.first.entity_type.titleize

    self.data = categories.map do |category|
      {
        name:   category.name,
        label:  category.label,
        icon:   category.icon,
        hidden: !!category.hidden,
        fields: (self.fields.select { |field| field.attribute_category_id == category.id }.map { |field|
          {
            id:     field.name,
            label:  field.label,
            type:   field.field_type,
            hidden: !!field.hidden,
            position: field.position,
            old_column_source: field.old_column_source,
            value: ""
          }
        }).sort do |a, b|
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

          if a[:position] && b[:position]
            a[:position] <=> b[:position]
          else
            a_value <=> b_value
          end
        end
      }
    end

    #raise self.data.inspect
  end

  # {
  #   'overview': [
  #     {
  #       id: 'children',
  #       label: 'Children',
  #       relation: 'Character',
  #       type: 'link',
  #       value: [Character, Character, Character]
  #     },
  #     ...
  #   ]
  # }
  # def old_style_link_fields
  #   categories = Hash[YAML.load_file(Rails.root.join('config', 'attributes', "#{self.class_name.downcase}.yml")).map do |category_name, details|
  #     [
  #       category_name.to_s,
  #       (details[:attributes] || []).select { |field| field[:field_type] == 'link'}.map do |field|
  #         {
  #           id:    field[:name],
  #           label: field[:label],
  #           type:  field[:field_type].presence || 'textarea',
  #           old_column_source: field[:name],
  #           value: ""
  #         }
  #       end
  #     ]
  #   end]
  # end
end
