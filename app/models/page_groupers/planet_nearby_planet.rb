class PlanetNearbyPlanet < ApplicationRecord
  include HasContentLinking
  LINK_TYPE = :two_way

  belongs_to :user, optional: true
  belongs_to :planet
  belongs_to :nearby_planet, class_name: Planet.name, optional: true

  # after_create do
  #   self.reciprocate(
  #     relation:          :planet_nearby_planets,
  #     parent_object_ref: :planet,
  #     added_object_ref:  :nearby_planet
  #   )
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Planet.find_by(id: self.planet_id)
  #   other_object = Planet.find_by(id: self.nearby_planet_id)

  #   other_object.nearby_planets.delete(this_object)
  # end
end
