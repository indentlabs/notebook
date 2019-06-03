require 'active_support/concern'

module HasAttributes
  extend ActiveSupport::Concern

  included do
    attr_accessor :custom_attribute_values
    after_save :update_custom_attributes

    def self.create_default_attribute_categories(user)
      return [] if ['attribute_category', 'attribute_field'].include?(content_name)

      categories = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_name}.yml")).map do |category_name, details|
        category = user.attribute_categories.create!(
          entity_type: self.content_name,
          name:        category_name.to_s,
          icon:        details[:icon],
          label:       details[:label]
        )

        category.attribute_fields << details[:attributes].map do |field|
          af_field = category.attribute_fields.with_deleted.create!(
            old_column_source: field[:name],
            user:              user,
            field_type:        field[:field_type].presence || "text_area",
            label:             field[:label].presence || 'Untitled field'
          )
          af_field
        end if details.key?(:attributes)
      end.compact
    end

    def self.attribute_categories(user, show_hidden: false)
      return [] if ['attribute_category', 'attribute_field'].include?(content_name)
      # This doesn't work the way I think it does
      #return @cached_attribute_categories_for_this_content if @cached_attribute_categories_for_this_content

      # Always include  the flatfile categories (but create AR versions if they don't exist)
      categories = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_name}.yml")).map do |category_name, details|
        category = AttributeCategory.with_deleted.find_or_initialize_by(
          entity_type: self.content_name,
          name: category_name.to_s,
          user: user
        )
        # Default new categories to some sane defaults
        unless category.persisted?
          category.icon = details[:icon]
          category.label = details[:label]
        end

        category.save! if user && category.new_record?
        category.attribute_fields << details[:attributes].map do |field|
          af_field = category.attribute_fields.with_deleted.find_or_initialize_by(
            # label: field[:label],
            old_column_source: field[:name],
            user: user,
            field_type: field[:field_type].presence || "text_area"
          )
          if af_field.label.nil?
            af_field.label = field[:label]
          end
          if user && af_field.new_record?
            af_field.save!
          end
          af_field
        end if details.key?(:attributes)

        if show_hidden
          category
        else
          !!category.hidden ? nil : category
        end
      end.compact

      # Cache the result in case we call this function multiple times this request
      @cached_attribute_categories_for_this_content = begin
        if categories.first&.user&.present?
          acceptable_hidden_values = show_hidden ? [true, false, nil] : [false, nil]
          categories
            .first
            .user
            .attribute_categories
              .where(entity_type: self.content_name, hidden: acceptable_hidden_values)
              .eager_load(attribute_fields: :attribute_values)
              .order('attribute_categories.position, attribute_categories.created_at, attribute_categories.id')

            # We need to do something like this, but... not this.
            #.eager_load(attribute_fields: :attribute_values) # .eager_load(:attribute_fields)
        else
          categories
        end
      end

      @cached_attribute_categories_for_this_content
    end

    # Replacement method for the above that doesn't make create calls, for use after everyone is migrated
    # def self.attribute_categories(user, show_hidden: false)
    #   return [] if ['attribute_category', 'attribute_field'].include?(content_name)

    #   # This doesn't work the way I think it does
    #   #return @cached_attribute_categories_for_this_content if @cached_attribute_categories_for_this_content

    #   # Always include  the flatfile categories (but create AR versions if they don't exist)
    #   categories = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_name}.yml")).map do |category_name, details|
    #     category = AttributeCategory.with_deleted.find_by(
    #       entity_type: self.content_name,
    #       name:        category_name.to_s,
    #       user:        user
    #     )

    #     category.attribute_fields << details[:attributes].map do |field|
    #       category.attribute_fields.with_deleted.find_by(
    #         user:              user,
    #         old_column_source: field[:name],
    #         field_type:        field[:field_type].presence || "text_area"
    #       )
    #     end if details.key?(:attributes)

    #     if show_hidden
    #       category
    #     else
    #       !!category.hidden ? nil : category
    #     end
    #   end.compact

    #   # Cache the result in case we call this function multiple times this request
    #   @cached_attribute_categories_for_this_content = begin
    #     if categories.first&.user&.present?
    #       acceptable_hidden_values = show_hidden ? [true, false, nil] : [false, nil]
    #       categories
    #         .first
    #         .user
    #         .attribute_categories
    #           .where(entity_type: self.content_name, hidden: acceptable_hidden_values)
    #           .eager_load(attribute_fields: :attribute_values)
    #           .order('attribute_categories.position, attribute_categories.created_at, attribute_categories.id')

    #         # We need to do something like this, but... not this.
    #         #.eager_load(attribute_fields: :attribute_values) # .eager_load(:attribute_fields)
    #     else
    #       categories
    #     end
    #   end

    #   @cached_attribute_categories_for_this_content
    # end

    def update_custom_attributes
      (self.custom_attribute_values || []).each do |attribute|
        field = AttributeField.includes(:attribute_category).find_by(
          name: attribute[:name],
          user: self.user,
          attribute_categories: { entity_type: self.class.name.downcase }
        )
        #todo why is this commented out? is it needed?
        #next if field.nil?
        raise "unknown field for attribute: #{attribute.inspect}" if field.nil?

        d = field.attribute_values.find_or_initialize_by(
          attribute_field_id: field.id,
          entity_type: self.class.name,
          entity_id: self.id,
          user: self.user
        )
        if d.value != attribute[:value] || d.new_record?
          d.value = attribute[:value]
          d.save!
        end
      end
    end

    def name_field
      category_ids = AttributeCategory.where(
        user_id: user_id,
        entity_type: self.class.name.downcase
      ).pluck(:id)

      # Todo these two queries should be able to be joined into one
      name_field = AttributeField.find_by(
        user_id: user_id,
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

    def overview_field(label)
      category_ids = AttributeCategory.where(
        user_id: user_id,
        entity_type: self.class.name.downcase
      ).pluck(:id)

      # Todo these two queries should be able to be joined into one
      field = AttributeField.find_by(
        user_id: user_id,
        attribute_category_id: category_ids,
        label: label,
        hidden: [nil, false]
      )
    end

    def name_field_value
      @name_field_lookup_cache ||= {}
      cache_key = "#{self.class.name}-#{self.id.to_s}"

      if @name_field_lookup_cache.key?(cache_key)
        return @name_field_lookup_cache[cache_key]
      end

      name_field_cache = name_field
      if name_field_cache.nil?
        @name_field_lookup_cache[cache_key] = self.name
        return self.name
      end

      field_value = name_field_cache.attribute_values.detect { |v| v.entity_id == self.id }&.value.presence || self.name.presence || "Untitled #{self.class.name}"
      @name_field_lookup_cache[cache_key] = field_value

      field_value
    end

    def universe_field_value
      universe_field_cache = universe_field
      return nil unless self.respond_to?(:universe_id)
      return self.universe_id if universe_field_cache.nil?

      universe_id = universe_field_cache.attribute_values.detect do |v|
        v.entity_id == self.id
      end&.value.presence || self.universe_id.presence || nil

      if universe_id
        Universe.find_by(id: universe_id.to_i)
      else
        nil
      end
    end

    def overview_field_value(label)
      field_cache = overview_field(label)
      return nil if field_cache.nil?

      field_cache.attribute_values.detect { |v| v.entity_id == self.id }&.value.presence || (self.respond_to?(label.downcase) ? self.read_attribute(label.downcase) : nil)
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
