class LandmarkFlora < ApplicationRecord
  belongs_to :user
  belongs_to :landmark
  belongs_to :flora
end
