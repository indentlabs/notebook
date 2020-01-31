class ContinentLandmark < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :continent
  belongs_to :landmark
end
