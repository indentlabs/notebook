class LoreFood < ApplicationRecord
  belongs_to :lore
  belongs_to :food, optional: true
  
  belongs_to :user, optional: true
end
