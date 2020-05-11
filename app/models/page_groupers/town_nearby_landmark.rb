class TownNearbyLandmark < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :town
  belongs_to :nearby_landmark, class_name: 'Landmark', optional: true
end
