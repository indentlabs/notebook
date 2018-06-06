require 'active_support/concern'

module HasAttributes
  extend ActiveSupport::Concern

  included do
    def self.create_default_page_categories_and_fields!(universe)
      class_name = self.name

      defaults = YAML.load_file(Rails.root.join('config', 'attributes', "#{class_name.downcase}.yml"))
      defaults.each do |category_name, category_data|
        puts "Creating default page categories for #{category_name}"

        # [2] pry(Character)> defaults.keys
        # => [:overview, :looks, :nature, :social, :history, :family, :inventory, :gallery, :changelog, :notes]
        # [3] pry(Character)> defaults[:overview]
        # => {:label=>"Overview",
        #  :icon=>"info",
        #  :attributes=>
        #   [{:name=>"name", :label=>"Name"},
        #    {:name=>"role", :label=>"Role"},
        #    {:name=>"aliases", :label=>"Other names"},
        #    {:name=>"gender", :label=>"Gender"},
        #    {:name=>"age", :label=>"Age"},
        #    {:name=>"universe_id", :label=>"Universe"}]}
        next unless category_data[:attributes].present?

        category = PageCategory.find_or_create_by(
          label: category_data[:label],
          icon: category_data[:icon],
          universe: universe,
          content_type: class_name
        )

        category_data[:attributes].each do |field_data|
          # We're keeping these two fields on the model
          next if [:name, :privacy].include?(field_data[:name])

          # We don't want to include real links quite yet
          next if field_data[:name].end_with?('_id')

          category.page_fields.find_or_create_by(
            label: field_data[:label]
          )
        end
      end
    end

    def page_categories
      queryable_universe_id = if self.is_a?(Universe)
        self.id
      elsif self.respond_to?(:universe) && self.universe.present?
        self.universe.id
      elsif self.respond_to?(:universe) && self.universe.nil?
        nil
      end

      PageCategory.where(universe_id: queryable_universe_id, content_type: self.class.name)
    end

    def page_fields
      page_category_ids = page_categories.pluck(:id)
      PageField.where(page_category_id: page_category_ids)
    end

    # TODO remove below this line after releasing pagecategories/pagefields

    attr_accessor :custom_attribute_values
    after_save :update_custom_attributes

    def self.attribute_categories(user = nil)
      categories = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_name}.yml")).map do |category_name, details|
        category = AttributeCategory.new(entity_type: self.content_name, name: category_name.to_s, label: details[:label], icon: details[:icon])
        category.attribute_fields << details[:attributes].map { |field| AttributeField.new(field.merge(system: true)) } if details.key? :attributes
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
