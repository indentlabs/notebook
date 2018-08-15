class LocationLargestTown < ApplicationRecord
  belongs_to :location
  belongs_to :user
  belongs_to :largest_town, class_name: Town.name
end
