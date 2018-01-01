class LandmarkCreature < ActiveRecord::Base
  belongs_to :user
  belongs_to :landmark
  belongs_to :creature
end
