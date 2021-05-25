class SerendipitousService < Service
  def self.question_for(content)
    return unless content.present?

    categories_for_this_type = AttributeCategory.where(
      user:        content.user,
      entity_type: content.class.name.downcase,
      hidden:      [nil, false]
    )

    # TODO: we should remove this at some point. How do we know when it's safe to do so?
    # TODO: is this what creates new fields/categories for new users? hopefully not.
    if categories_for_this_type.empty? && content.present?
      # If this page type has no categories, it needs migrated to the new attribute system
      TemporaryFieldMigrationService.migrate_fields_for_content(content, content.user)
    end
    #raise categories_for_this_type.pluck(:label).inspect
  
    fields_for_these_categories = AttributeField.where(
      user:        content.user,
      field_type:  "text_area",
      hidden:      [nil, false],
      attribute_category_id: categories_for_this_type.pluck(:id)
    )
    #raise fields_for_these_categories.pluck(:label).inspect
  
    attribute_fields_with_values = Attribute.where(
      entity_type: content.class.name,
      entity_id:   content.id,
      attribute_field_id: fields_for_these_categories.pluck(:id)
    ).where.not(
      value:       ["", nil]
    ).pluck(:attribute_field_id)
    # raise attribute_fields_with_values.inspect
    # raise attribute_fields_with_values.inspect
  
    if fields_for_these_categories.any?
      questionable_field_ids = fields_for_these_categories.pluck(:id) - attribute_fields_with_values
      attribute_field_to_question = AttributeField.find_by(id: questionable_field_ids.sample)
    end

    attribute_field_to_question
  end
end