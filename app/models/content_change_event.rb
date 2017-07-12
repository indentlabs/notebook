class ContentChangeEvent < ActiveRecord::Base
  belongs_to :user

  serialize :changed_fields, Hash
end
