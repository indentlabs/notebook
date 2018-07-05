class LargestCitiesRelationship < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :location
  belongs_to :largest_city, class_name: 'Location'
end
