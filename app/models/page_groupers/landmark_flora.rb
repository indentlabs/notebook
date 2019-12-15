class LandmarkFlora < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :landmark
  belongs_to :flora
end
