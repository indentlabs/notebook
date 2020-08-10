class LocationLandmark < ApplicationRecord
  belongs_to :location
  belongs_to :landmark, optional: true
  belongs_to :user, optional: true
end
