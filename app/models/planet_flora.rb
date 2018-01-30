class PlanetFlora < ActiveRecord::Base
  belongs_to :user
  belongs_to :planet
  belongs_to :flora
end
