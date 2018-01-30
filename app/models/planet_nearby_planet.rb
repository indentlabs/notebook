class PlanetNearbyPlanet < ActiveRecord::Base
  belongs_to :user
  belongs_to :planet
end
