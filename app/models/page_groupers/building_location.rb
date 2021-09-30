class BuildingLocation < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :building
  belongs_to :location
end
