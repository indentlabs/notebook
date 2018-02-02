class DeityRelatedLandmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :deity
  belongs_to :related_landmark, class_name: Landmark.name
end
