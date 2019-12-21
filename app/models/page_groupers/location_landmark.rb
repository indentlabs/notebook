class LocationLandmark < ApplicationRecord
  belongs_to :location
  belongs_to :landmark
  belongs_to :user, optional: true
end
