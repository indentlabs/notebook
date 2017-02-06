class GroupAllyship < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :ally, class_name: 'Group'
end