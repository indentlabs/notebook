class GroupAllyship < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :ally, class_name: 'Group'

  after_create do
    self.reciprocate relation: :group_allyships, parent_object_ref: :group, added_object_ref: :ally
  end

  after_destroy do
    # This is a two-way relation, so we should also delete the reverse association
    this_object  = Group.find_by(id: self.group_id)
    other_object = Group.find_by(id: self.ally_id)

    other_object.allies.delete this_object
  end
end
