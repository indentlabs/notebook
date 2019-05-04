class ContentChangeEvent < ApplicationRecord
  belongs_to :user

  serialize :changed_fields, Hash

  def content
    content_type.constantize.find_by(id: content_id)
  end
  
  def entity
    content.try(:entity) || content
  end
end
