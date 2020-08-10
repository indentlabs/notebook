class LoreCreature < ApplicationRecord
  belongs_to :lore
  belongs_to :creature, optional: true
  
  belongs_to :user, optional: true
end
