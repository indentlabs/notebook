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
      self.attribute_values.detect { |value| 
        value.entity_type        == content.page_type &&
        value.entity_id          == content.id &&
        value.attribute_field_id == attribute_field.id
      }.try(:value) || ""
    end
  end
end
