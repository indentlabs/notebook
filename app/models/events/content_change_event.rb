class ContentChangeEvent < ApplicationRecord
  belongs_to :user

  serialize :changed_fields, Hash

  def content
    content_type.constantize.find(content_id)
  end
end
