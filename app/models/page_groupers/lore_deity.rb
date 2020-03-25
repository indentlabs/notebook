class LoreDeity < ApplicationRecord
  belongs_to :lore
  belongs_to :deity
  
  belongs_to :user, optional: true
end
