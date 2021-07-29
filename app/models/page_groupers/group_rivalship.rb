class GroupRivalship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :group
  belongs_to :rival, class_name: 'Group', optional: true

  # after_create do
  #   self.reciprocate relation: :group_rivalships, parent_object_ref: :group, added_object_ref: :rival
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Group.find_by(id: self.group_id)
  #   other_object = Group.find_by(id: self.rival_id)

  #   other_object.rivals.delete this_object
  # end
end
