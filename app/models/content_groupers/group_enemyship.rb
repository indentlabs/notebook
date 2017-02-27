class GroupEnemyship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :enemy, class_name: 'Group'
end