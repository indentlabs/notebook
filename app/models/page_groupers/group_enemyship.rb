class GroupEnemyship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :group
  belongs_to :enemy, class_name: 'Group', optional: true

  # after_create do
  #   self.reciprocate relation: :group_enemyships, parent_object_ref: :group, added_object_ref: :enemy
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Group.find_by(id: self.group_id)
  #   other_object = Group.find_by(id: self.enemy_id)

  #   other_object.enemies.delete(this_object) if other_object.present?
  # end
end
