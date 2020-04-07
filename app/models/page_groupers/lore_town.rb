class LoreTown < ApplicationRecord
  belongs_to :lore
  belongs_to :town
  
  belongs_to :user, optional: true
end
