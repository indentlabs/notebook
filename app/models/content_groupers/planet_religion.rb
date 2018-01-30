class PlanetReligion < ActiveRecord::Base
  belongs_to :user
  belongs_to :planet
  belongs_to :religion
end
