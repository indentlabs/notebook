class ItemMagic < ApplicationRecord
  belongs_to :item
  belongs_to :magic, optional: true
  belongs_to :user, optional: true
end
