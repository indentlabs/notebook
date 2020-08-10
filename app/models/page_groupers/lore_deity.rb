class LoreDeity < ApplicationRecord
  belongs_to :lore
  belongs_to :deity, optional: true
  
  belongs_to :user, optional: true
end
