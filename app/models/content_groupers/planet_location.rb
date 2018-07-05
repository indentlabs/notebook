class PlanetLocation < ApplicationRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :location
end
