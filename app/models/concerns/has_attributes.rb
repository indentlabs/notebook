require 'active_support/concern'

module HasAttributes
  extend ActiveSupport::Concern

  included do
    attr_accessor :custom_attribute_values
    after_save :update_custom_attributes

    def self.create_default_attribute_categories(user)
      # Don't create any attribute categories for AttributeCategories or AttributeFields that share the ContentController
      return [] if ['attribute_category', 'attribute_field'].include?(content_name)

      YAML.load_file(Rails.root.join('config', 'attributes', "#{content_name}.yml")).map do |category_name, defaults|
        # First, query for the category to see if it already exists
        category = user.attribute_categories.find_or_initialize_by(
          entity_type: self.content_name,
          name:        category_name.to_s
        )
        creating_new_category = category.new_record?

        # If the category didn't already exist, go ahead and set defaults on it and save
        if creating_new_category
          category.label = defaults[:label]
          category.icon  = defaults[:icon]
          category.save!
        end

        # If we created this category for the first time, we also want to make sure we create its default fields, too
        if creating_new_category && defaults.key?(:attributes)
          category.attribute_fields << defaults[:attributes].map do |field|
            af_field = category.attribute_fields.with_deleted.create!(
              old_column_source: field[:name],
              user:              user,
              field_type:        field[:field_type].presence || "text_area",
              label:             field[:label].presence      || 'Untitled field'
            )
            af_field
          end
        end
      end.compact
    end

    def self.attribute_categories(user, show_hidden: false)
      # TODO: this is a code smell; we should probably either be whitelisting or fixing whatever is calling
      #       this with the wrong models
      return [] if ['attribute_category', 'attribute_field'].include?(content_name)

      # Cache the result in case we call this function multiple times this request
      @cached_attribute_categories_for_this_content = begin
        # Always include  the flatfile categories (but create AR versions if they don't exist)
        categories_list  = AttributeCategory.with_deleted.where(user: user).to_a
        full_fields_list = AttributeField.with_deleted.where(user: user, attribute_category_id: categories_list.map(&:id))
        categories = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_name}.yml")).map do |category_name, details|
          category = categories_list.detect do |persisted_category|
            persisted_category.entity_type == self.content_name &&
            persisted_category.name        == category_name.to_s
          end
          if category.nil?
            category = AttributeCategory.new(
              entity_type: self.content_name,
              name:        category_name.to_s,
              user:        user
            )
          end

          # Default new categories to some sane defaults
          unless category.persisted?
            category.icon  = details[:icon]
            category.label = details[:label]
          end

          category.save! if user && category.new_record?
          fields_list = full_fields_list.select do |field|
            field.attribute_category_id == category.id
          end
          category.attribute_fields << details[:attributes].map do |field|
            af_field = fields_list.detect do |persisted_field|
              persisted_field.old_column_source == field[:name] &&
              persisted_field.field_type        == field[:field_type].presence || "text_area"
            end
            if af_field.nil?
              af_field = category.attribute_fields.new(
                old_column_source: field[:name],
                user:              user,
                field_type:        field[:field_type].presence || "text_area"
              )
            end
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
            #.eager_load(attribute_fields: :attribute_values)
            #.eager_load(:attribute_fields)
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
    #     category = ::AttributeCategory.with_deleted.find_by(
    #       entity_type: self.content_name,
    #       name:        category_name.to_s,
    #       user:        user
    #     )

    #     # category.attribute_fields << details[:attributes].map do |field|
    #     #   category.attribute_fields.with_deleted.find_by(
    #     #     user:              user,
    #     #     old_column_source: field[:name],
    #     #     field_type:        field[:field_type].presence || "text_area"
    #     #   )
    #     # end if details.key?(:attributes)

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
        field = AttributeField.includes(:attribute_category).find_by(  # THIS GETS CALLED A TON
          name: attribute[:name],
          user: self.user,
          attribute_categories: { entity_type: self.class.name.downcase }
        )
        #todo why is this commented out? is it needed?
        #next if field.nil?
        raise "unknown field for attribute: #{attribute.inspect}" if field.nil?

        d = field.attribute_values.find_or_initialize_by(  # THIS ALSO GETS CALLED A TON
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

    # All of these helpers are spooky and rife for N+1s
    def name_field
      category_ids = AttributeCategory.where(
        user_id: user_id,
        entity_type: self.class.name.downcase
      ).pluck(:id)

      # Todo these two queries should be able to be joined into one
      AttributeField.find_by(
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
      AttributeField.find_by(
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
      AttributeField.find_by(
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

    def set_name_field_value(field_value)
      field = name_field
      value = field.attribute_values.find_or_create_by(
        user_id:     self.user_id,
        entity_type: self.class.name,
        entity_id:   self.id,
      )

      value.update(value: field_value)
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

      field_cache
        .attribute_values
        .order('created_at desc')
        .detect { |v| v.entity_id == self.id }&.value.presence || (self.respond_to?(label.downcase) ? self.read_attribute(label.downcase) : nil)
    end

    def get_field_value(category, field)
      category = AttributeCategory.find_by(
        label:       category,
        entity_type: self.class.name.downcase,
        user_id:     self.user_id,
        hidden:      [nil, false]
      )
      return nil if category.nil?

      field = AttributeField.find_by(
        label:                 field,
        attribute_category_id: category.id,
        user_id:               self.user_id,
        hidden:                [nil, false]
      )
      return nil if field.nil?

      answer = Attribute.find_by(
        attribute_field_id: field.id,
        entity_type:        self.class.name,
        entity_id:          self.id,
        user_id:            self.user_id
      )
      return nil if answer.nil?

      answer.value
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
