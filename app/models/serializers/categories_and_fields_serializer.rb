class CategoriesAndFieldsSerializer
  attr_accessor :data
  attr_accessor :categories, :fields

  attr_accessor :class_name

  def initialize(categories)
    self.categories = categories
    categories = categories.dup.to_a

    self.fields     = AttributeField.where(attribute_category_id: categories.map(&:id)).to_a
    self.class_name = categories.first.entity_type.titleize

    self.data = categories.map do |category|
      {
        name:   category.name,
        label:  category.label,
        icon:   category.icon,
        hidden: !!category.hidden,
        fields: (self.fields.select { |field| field.attribute_category_id == category.id }.map { |field|
          {
            internal_id: field.id,
            id:          field.name,
            label:       field.label,
            type:        field.field_type,
            hidden:      !!field.hidden,
            position:    field.position,
            value:       "",
            old_column_source: field.old_column_source # deprecated -- we should remove this
          }
        }).sort do |a, b|
           if a[:position] && b[:position]	
            a[:position] <=> b[:position]

          else	
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
            
            a_value <=> b_value	
          end	
        end
      }
    end
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
end
