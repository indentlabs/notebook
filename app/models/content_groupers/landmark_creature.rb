class LandmarkCreature < ActiveRecord
  belongs_to :user
  belongs_to :landmark
  belongs_to :creature
end
