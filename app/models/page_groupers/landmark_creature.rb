class LandmarkCreature < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :landmark
  belongs_to :creature, optional: true
end
