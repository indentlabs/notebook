class LoreTown < ApplicationRecord
  belongs_to :lore
  belongs_to :town, optional: true
  
  belongs_to :user, optional: true
end
