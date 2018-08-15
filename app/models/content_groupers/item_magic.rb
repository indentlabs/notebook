class ItemMagic < ApplicationRecord
  belongs_to :item
  belongs_to :magic
  belongs_to :user
end
