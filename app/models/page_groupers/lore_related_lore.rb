class LoreRelatedLore < ApplicationRecord
  include HasContentLinking

  belongs_to :lore
  belongs_to :related_lore, class_name: Lore.name, optional: true

  belongs_to :user, optional: true

  # after_create do
  #   self.reciprocate relation: :lore_related_lores, parent_object_ref: :lore, added_object_ref: :related_lore
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Lore.find_by(id: self.lore_id)
  #   other_object = Lore.find_by(id: self.related_lore_id)

  #   other_object.related_lores.delete(this_object) if other_object.present?
  # end
end
