class ReligiousLocationship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :religion
  belongs_to :practicing_location, class_name: 'Location'
end
