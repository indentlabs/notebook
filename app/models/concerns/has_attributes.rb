require 'active_support/concern'

module HasAttributes
  extend ActiveSupport::Concern

  included do
    attr_accessor :attribute_values
    after_save :update_attribute_values

    def self.attribute_categories
      YAML.load_file(Rails.root.join('config', 'attributes', "#{content_name}.yml")).map do |category_name, details|
        category = AttributeCategory.new(entity_type: self.name, name: category_name.to_s, label: details[:label], icon: details[:icon])
        category.attribute_fields << details[:attributes].map { |field| AttributeField.new(field.merge(system: true)) }
        category
      end
    end

    def update_attribute_values
      (self.attribute_values || []).each do |attribute|
        field = user.attribute_fields.find_by_name(attribute[:name])
        next if field.nil?

        user.custom_attributes.where(entity: self, attribute_field_id: field.id).first_or_create(value: attribute[:value])
      end
    end
  end
end
