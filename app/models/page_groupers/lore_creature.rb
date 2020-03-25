class LoreCreature < ApplicationRecord
  belongs_to :lore
  belongs_to :creature
  
  belongs_to :user, optional: true
end
