class PlanetGroup < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :planet
  belongs_to :group, optional: true
end
