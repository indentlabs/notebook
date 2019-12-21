class TownFlora < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :town
  belongs_to :flora
end
