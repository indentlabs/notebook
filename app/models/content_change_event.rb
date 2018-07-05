class ContentChangeEvent < ActiveRecord
  belongs_to :user

  serialize :changed_fields, Hash
end
