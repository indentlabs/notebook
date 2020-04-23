class LoreMagic < ApplicationRecord
  belongs_to :lore
  belongs_to :magic
  
  belongs_to :user, optional: true
end
