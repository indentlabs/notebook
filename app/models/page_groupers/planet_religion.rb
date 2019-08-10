class PlanetReligion < ApplicationRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :religion
end
