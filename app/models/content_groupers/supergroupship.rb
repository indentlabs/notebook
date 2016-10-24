class Supergroupship < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :supergroup, class_name: 'Group'
end