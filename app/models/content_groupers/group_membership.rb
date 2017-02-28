class GroupMembership < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :member, class_name: 'Character'
end