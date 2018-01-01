class LandmarkFlora < ActiveRecord::Base
  belongs_to :user
  belongs_to :landmark
  belongs_to :flora
end
