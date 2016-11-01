class GroupEnemyship < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :enemy, class_name: 'Group'
end