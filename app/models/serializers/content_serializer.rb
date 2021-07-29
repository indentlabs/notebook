class ContentSerializer
  attr_accessor :id, :name, :user, :universe

  attr_accessor :categories
  attr_accessor :fields
  attr_accessor :attribute_values
  attr_accessor :page_tags
  attr_accessor :documents

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

    self.page_tags        = content.page_tags.pluck(:tag) || []
    self.documents        = content.documents || []

    self.data = {
      name: content.try(:name),
      description: content.try(:description),
      universe: self.universe.nil? ? nil : {
        id:   self.universe.id,
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
              internal_id:       field.id,
              id:                field.name,
              label:             field.label,
              type:              field.field_type,
              hidden:            !!field.hidden,
              position:          field.position,
              value:             value_for(field, content),
              options:           field.field_options,
              migrated_link:     field.migrated_from_legacy,    
              old_column_source: field.old_column_source
            }
          }.sort do |a, b|
            if a[:position] && b[:position]
              a[:position] <=> b[:position]

            else
              # TODO why do we still have this?
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
      }
    }

    # Do a little number crunching
    self.data[:categories].each do |category|
      completed_fields = category[:fields].select { |field| field[:value].present? }.count.to_f
      total_fields = category[:fields].count

      if total_fields.zero?
        category[:percent_complete] = nil
      else
        category[:percent_complete] = (completed_fields / total_fields * 100).round
      end
    end

    self.data
  end

  def value_for(attribute_field, content)
    case attribute_field.field_type
    when 'link'
      page_links = attribute_field.attribute_values.find_by(entity_type: content.class.name, entity_id: content.id)
      if page_links.nil?
        # Fall back on old relation value
        # We're technically doing a double lookup here (by converting response
        # to link code, then looking up again later) but since this is just stopgap
        # code to standardize links in views this should be fine for now.
        if attribute_field.old_column_source.present?
          self.raw_model.send(attribute_field.old_column_source).map { |page| "#{page.page_type}-#{page.id}" }
        else
          []
        end

      else
        # Use new link system
        begin
          JSON.parse(page_links.value)
        rescue
          if page_links.value == ""
            []
          else
            "Error loading Attribute ID #{page_links.id}"
          end
        end
      end

    when 'tags'
      self.page_tags

    else # text_area, name, universe, etc
      #codesmell here: we shouldn't ever have multiple attribute values but for some reason we do sometimes (in collaboration?)
      self.attribute_values.order('created_at desc').detect { |value| 
        value.entity_type        == content.page_type &&
        value.entity_id          == content.id &&
        value.attribute_field_id == attribute_field.id
      }.try(:value) || ""
    end
  end
end
