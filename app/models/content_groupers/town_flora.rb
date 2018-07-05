class TownFlora < ApplicationRecord
  belongs_to :user
  belongs_to :town
  belongs_to :flora
end
