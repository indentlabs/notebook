class GroupClientship < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :client, class_name: 'Group'
end
