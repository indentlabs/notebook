class PlanetLandmark < ActiveRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :landmark
end
