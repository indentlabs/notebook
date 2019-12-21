class TechnologyCreature < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :technology
  belongs_to :creature
end
