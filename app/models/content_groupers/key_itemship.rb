class KeyItemship < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :key_item, class_name: 'Item'
end