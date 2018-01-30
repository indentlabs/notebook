class PlanetCreature < ActiveRecord::Base
  belongs_to :user
  belongs_to :planet
  belongs_to :creature
end
