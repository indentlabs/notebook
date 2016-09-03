class LargestCitiesRelationship < ActiveRecord::Base
  belongs_to :user

  belongs_to :location
  belongs_to :largest_city, class_name: 'Location'
end
