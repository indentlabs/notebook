class GroupClientship < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :client, class_name: 'Group'
end