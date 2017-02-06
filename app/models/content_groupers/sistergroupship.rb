class Sistergroupship < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :sistergroup, class_name: 'Group'
end