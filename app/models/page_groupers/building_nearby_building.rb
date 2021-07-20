class BuildingNearbyBuilding < ApplicationRecord
  include HasContentLinking

  LINK_TYPE = :two_way

  belongs_to :user, optional: true
  belongs_to :building
  belongs_to :nearby_building, class_name: Building.name, optional: true

  after_create do
    self.reciprocate(
      relation:          :building_nearby_buildings, 
      parent_object_ref: :building, 
      added_object_ref:  :nearby_building
    )
  end

  after_destroy do
    # This is a two-way relation, so we should also delete the reverse association
    this_object  = Building.find_by(id: self.building)
    other_object = Building.find_by(id: self.nearby_building_id)

    other_object.nearby_buildings.delete(this_object) if other_object.present?
  end
end
