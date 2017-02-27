class Supergroupship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :supergroup, class_name: 'Group'
end