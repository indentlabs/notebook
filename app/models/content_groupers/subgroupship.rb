class Subgroupship < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :subgroup, class_name: 'Group'
end