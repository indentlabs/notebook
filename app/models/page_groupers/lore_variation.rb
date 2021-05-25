class LoreVariation < ApplicationRecord
  include HasContentLinking

  belongs_to :lore
  belongs_to :variation, class_name: Lore.name, optional: true
  
  belongs_to :user, optional: true

  # after_create do
  #   self.reciprocate relation: :lore_variations, parent_object_ref: :lore, added_object_ref: :variation
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Lore.find_by(id: self.lore_id)
  #   other_object = Lore.find_by(id: self.variation_id)

  #   other_object.related_lores.delete(this_object) if other_object.present?
  # end
end
