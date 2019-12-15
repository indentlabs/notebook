class GroupEquipmentship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :group
  belongs_to :equipment, class_name: 'Item'
end
