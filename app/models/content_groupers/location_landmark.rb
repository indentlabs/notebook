class LocationLandmark < ActiveRecord::Base
  belongs_to :location
  belongs_to :landmark
  belongs_to :user
end
