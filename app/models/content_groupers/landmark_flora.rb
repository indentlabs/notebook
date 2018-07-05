class LandmarkFlora < ActiveRecord
  belongs_to :user
  belongs_to :landmark
  belongs_to :flora
end
