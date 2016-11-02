class GroupMembership < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :member, class_name: 'Character'
end