class LoreFood < ApplicationRecord
  belongs_to :lore
  belongs_to :food
  
  belongs_to :user, optional: true
end
