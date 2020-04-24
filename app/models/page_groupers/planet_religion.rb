class PlanetReligion < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :planet
  belongs_to :religion, optional: true
end
