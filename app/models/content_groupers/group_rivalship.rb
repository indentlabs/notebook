class GroupRivalship < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :rival, class_name: 'Group'
end