class DeityRelatedLandmark < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :related_landmark, class_name: Landmark.name
end
