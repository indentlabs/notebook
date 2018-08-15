class TechnologyTown < ApplicationRecord
  belongs_to :user
  belongs_to :technology
  belongs_to :town
end
