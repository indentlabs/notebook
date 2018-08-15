class LandmarkCreature < ApplicationRecord
  belongs_to :user
  belongs_to :landmark
  belongs_to :creature
end
