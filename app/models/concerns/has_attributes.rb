require 'active_support/concern'

module HasAttributes
  extend ActiveSupport::Concern

  included do
    attr_accessor :custom_attribute_values
    after_save :update_custom_attributes

    def self.attribute_categories(user = nil)
      categories = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_name}.yml")).map do |category_name, details|
        category = AttributeCategory.new(entity_type: self.content_name, name: category_name.to_s, label: details[:label], icon: details[:icon])
        category.attribute_fields << details[:attributes].map { |field| AttributeField.new(field.merge(system: true)) }
        category
      end

      return categories if user.nil?
      [categories, user.attribute_categories.where(['attribute_categories.entity_type = ?', content_name]).joins(:attribute_fields)].flatten.uniq
    end

    def update_custom_attributes
      (self.custom_attribute_values || []).each do |attribute|
        field = user.attribute_fields.find_by_name(attribute[:name])
        next if field.nil?

        user.attribute_values.where(entity: self, attribute_field_id: field.id).first_or_initialize.tap do |field|
          field.value = attribute[:value]
          field.save!
        end
      end
    end
  end
end
