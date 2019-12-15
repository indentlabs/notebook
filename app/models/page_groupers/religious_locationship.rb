class ReligiousLocationship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :religion
  belongs_to :practicing_location, class_name: 'Location'
end
