class ContentChangeEvent < ApplicationRecord
  belongs_to :user

  serialize :changed_fields, Hash

  # Don't show or create ContentChangeEvents for content changes on these attributes
  FIELD_IDS_TO_EXCLUDE = %w(
    id created_at updated_at user user_id
  )

  BLANK_PLACEHOLDER   = ''
  PRIVATE_PLACEHOLDER = '(hidden)'

  def content
    content_type.constantize.find_by(id: content_id)
  end
  
  def entity
    content.try(:entity) || content
  end
end
