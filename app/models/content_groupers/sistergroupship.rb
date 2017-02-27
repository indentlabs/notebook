class Sistergroupship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :sistergroup, class_name: 'Group'
end