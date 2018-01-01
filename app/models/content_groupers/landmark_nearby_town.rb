class LandmarkNearbyTown < ActiveRecord::Base
  belongs_to :user

  belongs_to :landmark
  belongs_to :nearby_town, class_name: 'Town'
end
