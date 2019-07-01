# This service moves attribute values from being directly stored on the model (e.g. Character#age)
# to the new-style of having values in an associated Attribute model.
# Once all data has been moved over, we can remove these old columns and delete this service.
class TemporaryFieldMigrationService < Service
  def self.migrate_all_content_for_user(user)
    user.content_list.each do |content|
      self.migrate_fields_for_content(content, user)
    end
  end

  def self.migrate_fields_for_content(content_model, user)
    return unless content_model.present? && user.present?
    return unless content_model.user == user
    return if content_model.persisted? && content_model.updated_at > 'September 1, 2018'.to_datetime

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

      if content_model.respond_to?(attribute_field.old_column_source)
        value_from_model = content_model.send(attribute_field.old_column_source)
        if value_from_model.present? && value_from_model != existing_value.try(:value)
          if existing_value
            existing_value.disable_changelog_this_request = true
            existing_value.update!(value: value_from_model)
            existing_value.disable_changelog_this_request = false
          else
            new_value = attribute_field.attribute_values.new(
              user_id:     content_model.user.id,
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
end
