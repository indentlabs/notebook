class PlanetDeity < ApplicationRecord
  belongs_to :user
  belongs_to :planet
  belongs_to :deity
end
