class GroupAllyship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :group
  belongs_to :ally, class_name: 'Group', optional: true

  # after_create do
  #   self.reciprocate relation: :group_allyships, parent_object_ref: :group, added_object_ref: :ally
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Group.find_by(id: self.group_id)
  #   other_object = Group.find_by(id: self.ally_id)

  #   other_object.allies.delete(this_object) if other_object.present?
  # end
end
