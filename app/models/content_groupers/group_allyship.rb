class GroupAllyship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :ally, class_name: 'Group'
end