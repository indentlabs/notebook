class LocationLargestTown < ApplicationRecord
  belongs_to :location
  belongs_to :user, optional: true
  belongs_to :largest_town, class_name: Town.name, optional: true
end
