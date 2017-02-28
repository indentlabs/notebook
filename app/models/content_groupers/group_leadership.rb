class GroupLeadership < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :leader, class_name: 'Character'
end