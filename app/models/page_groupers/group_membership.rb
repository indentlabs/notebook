class GroupMembership < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :group
  belongs_to :member, class_name: 'Character'
end
