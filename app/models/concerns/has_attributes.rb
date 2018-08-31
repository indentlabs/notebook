require 'active_support/concern'

module HasAttributes
  extend ActiveSupport::Concern

  included do
    attr_accessor :custom_attribute_values
    after_save :update_custom_attributes

    def self.attribute_categories(user, show_hidden: false)
      return [] if ['attribute_category', 'attribute_field'].include?(content_name)

      # Always include  the flatfile categories (but create AR versions if they don't exist)
      categories = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_name}.yml")).map do |category_name, details|
        category = AttributeCategory.with_deleted.find_or_initialize_by(
          entity_type: self.content_name,
          name: category_name.to_s,
          label: details[:label],
          icon: details[:icon],
          user: user,
          created_at: "January 1, 1970".to_datetime
        )
        next unless user

        category.save
        category.attribute_fields << details[:attributes].map do |field|
          af_field = AttributeField.with_deleted.find_or_initialize_by(
            attribute_category_id: category.reload.id,
            label: field[:label],
            old_column_source: field[:name],
            user: user,
            field_type: field[:field_type].presence || "text_area"
          )
          af_field.save! if user
          af_field
        end if details.key?(:attributes)

        if show_hidden
          category
        else
          !!category.hidden ? nil : category
        end
      end.compact

      if categories.first&.user&.present?
        acceptable_hidden_values = show_hidden ? [true, false, nil] : [false, nil]
        categories.first.user.attribute_categories.where(entity_type: self.content_name, hidden: acceptable_hidden_values).order('created_at, id')
      else
        categories
      end

      # todo make sure we don't need this? :)
      #[categories, user.attribute_categories.where(['attribute_categories.entity_type = ?', content_name]).joins(:attribute_fields)].flatten.uniq
    end

    def update_custom_attributes
      (self.custom_attribute_values || []).each do |attribute|
        field = AttributeField.find_by(name: attribute[:name])
        next if field.nil?

        d = field.attribute_values.find_or_initialize_by(
          attribute_field_id: field.id,
          entity_type: self.class.name,
          entity_id: self.id,
          user: user
        )
        d.value = attribute[:value]
        d.save!
      end
    end

    def name_field
      category_ids = AttributeCategory.where(
        user_id: user.id,
        entity_type: self.class.name.downcase
      ).pluck(:id)

      # Todo these two queries should be able to be joined into one
      name_field = AttributeField.find_by(
        user_id: user.id,
        attribute_category_id: category_ids,
        field_type: 'name'
      )
    end

    def universe_field
      category_ids = AttributeCategory.where(
        user_id: user_id,
        entity_type: self.class.name.downcase
      ).pluck(:id)

      # Todo these two queries should be able to be joined into one
      name_field = AttributeField.find_by(
        user_id: user_id,
        attribute_category_id: category_ids,
        field_type: 'universe'
      )
    end

    def name_field_value
      name_field_cache = name_field
      return self.name if name_field_cache.nil?

      name_field_cache.attribute_values.detect { |v| v.entity_id == self.id }&.value.presence || self.name.presence || "Untitled #{self.class.name}"
    end

    def universe_field_value
      universe_field_cache = universe_field
      return self.universe_id if universe_field_cache.nil?

      universe_id = universe_field_cache.attribute_values.detect do |v|
        v.entity_id == self.id
      end&.value.presence || self.universe_id.presence || nil

      if universe_id
        Universe.find(universe_id)
      else
        nil
      end
    end

    def self.field_type_for(category, field)
      if field[:label] == 'Name' && category.name == 'overview'
        "name"
      elsif field[:label] == 'Universe' && category.name == 'overview'
        "universe"
      else
        "textarea"
      end
    end
  end
end
