class CreatureRelationship < ApplicationRecord
  include HasContentLinking
  LINK_TYPE = :two_way

  belongs_to :user, optional: true

  belongs_to :creature
  belongs_to :related_creature, class_name: 'Creature', optional: true

  # after_create do
  #   self.reciprocate(
  #     relation:          :creature_relationships, 
  #     parent_object_ref: :creature, 
  #     added_object_ref:  :related_creature
  #   )
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Creature.find_by(id: self.creature_id)
  #   other_object = Creature.find_by(id: self.related_creature_id)

  #   other_object.related_creatures.delete(this_object) if other_object.present?
  # end
end
