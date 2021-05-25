class DeityDeitySibling < ApplicationRecord
  include HasContentLinking

  belongs_to :deity
  belongs_to :deity_sibling, class_name: Deity.name, optional: true
  belongs_to :user, optional: true

  # after_create do
  #   self.reciprocate(
  #     relation:          :deity_deity_siblings,
  #     parent_object_ref: :deity,
  #     added_object_ref:  :deity_sibling
  #   )
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Deity.find_by(id: self.deity_id)
  #   other_object = Deity.find_by(id: self.deity_sibling_id)

  #   other_object.deity_siblings.delete(this_object) unless other_object.nil?
  # end
end
