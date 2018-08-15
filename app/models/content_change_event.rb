class ContentChangeEvent < ApplicationRecord
  belongs_to :user

  serialize :changed_fields, Hash
end
