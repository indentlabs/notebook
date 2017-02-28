class GroupRivalship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :rival, class_name: 'Group'
end