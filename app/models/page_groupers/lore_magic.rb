class LoreMagic < ApplicationRecord
  belongs_to :lore
  belongs_to :magic, optional: true
  
  belongs_to :user, optional: true
end
