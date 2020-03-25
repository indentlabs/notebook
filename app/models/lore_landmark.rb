class LoreLandmark < ApplicationRecord
  belongs_to :lore
  belongs_to :landmark
  belongs_to :user
end
