class UpdateTextAttributeReferencesJob < ApplicationJob
  queue_as :mentions

  def perform(*args)
    attribute_id = args.shift

    attribute = Attribute.find_by(id: attribute_id)
    return unless attribute.present?

    # Create PageReferences for mentioned pages
    tokens = ContentFormatterService.tokens_to_replace(attribute.value)
    if tokens.any?
      entity = attribute.entity

      valid_reference_ids = []
      tokens.each do |token|
        reference = entity.outgoing_page_references.find_or_initialize_by(
          referenced_page_type:  token[:content_type],
          referenced_page_id:    token[:content_id],
          attribute_field_id:    attribute.attribute_field_id,
          reference_type:        'mentioned'
        )
        reference.cached_relation_title = AttributeField.find_by(id: attribute.attribute_field_id).try(:label)
        reference.save!

        valid_reference_ids << reference.reload.id
      end

      # Delete all other references still attached to this field, but not present in this request
      entity.outgoing_page_references
        .where(attribute_field_id: attribute.attribute_field_id)
        .where.not(id: valid_reference_ids)
        .destroy_all
    end
  end
end
