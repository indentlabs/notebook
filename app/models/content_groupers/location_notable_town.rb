class LocationNotableTown < ActiveRecord
  belongs_to :location
  belongs_to :user
  belongs_to :notable_town, class_name: Town.name
end
