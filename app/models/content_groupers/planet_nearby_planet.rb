class PlanetNearbyPlanet < ActiveRecord::Base
  belongs_to :user
  belongs_to :planet
  belongs_to :nearby_planet, class_name: Planet.name
end
