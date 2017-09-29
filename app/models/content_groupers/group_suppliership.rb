class GroupSuppliership < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :supplier, class_name: 'Group'
end