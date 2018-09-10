class TemporaryFieldMigrationService < Service
  def self.migrate_fields_for_content(content_model)
    # todo we might be able to do this in a single left outer join
    attribute_categories = content_model.class.attribute_categories(content_model.user)
    attribute_fields     = AttributeField.where(attribute_category_id: attribute_categories.pluck(:id))
                                         .where.not(field_type: 'link')
                                         .where.not(old_column_source: [nil, ""])

    # Do a quick check to see if there's exactly 1 existing attribute for each attribute field
    # on this model. This lets us avoid a ton of individual "are there any attribute values for
    # this field" queries below.
    existing_attribute_values_count = Attribute.where(
      attribute_field_id: attribute_fields.pluck(:id),
      entity_id:          content_model.id,
      entity_type:        content_model.class.name
    ).uniq.count
    if attribute_fields.count == existing_attribute_values_count
      return # hurrah!
    end

    # If we're gonna loop over each attribute field, we want to eager_load their attribute values also.
    attribute_fields.eager_load(:attribute_values)
    attribute_fields.each do |attribute_field|
      existing_value = attribute_field.attribute_values.find_by(
        entity_id:   content_model.id,
        entity_type: content_model.class.name
      )

      # If a user has touched this attribute's value since we've created it,
      # we don't want to touch it again.
      if existing_value && existing_value.created_at != existing_value.updated_at
        next
      end

      value_from_model = content_model.send(attribute_field.old_column_source)
      if value_from_model.present? && value_from_model != existing_value.value
        if existing_value
          existing_value.disable_changelog_this_request = true
          existing_value.update!(value: value_from_model)
          existing_value.disable_changelog_this_request = false
        else
          new_value = attribute_field.attribute_values.new(
            user_id:     current_user.id,
            entity_type: content_model.class.name,
            entity_id:   content_model.id,
            value:       value_from_model,
            privacy:     'private' # todo just make this the default for the column instead
          )

          new_value.disable_changelog_this_request = true
          new_value.save!
          new_value.disable_changelog_this_request = true
        end
      end
    end
  end
end
