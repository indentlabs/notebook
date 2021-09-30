class BuildingTown < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :building
  belongs_to :town
end
