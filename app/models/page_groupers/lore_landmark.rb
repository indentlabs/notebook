class LoreLandmark < ApplicationRecord
  belongs_to :lore
  belongs_to :landmark, optional: true
  
  belongs_to :user, optional: true
end
