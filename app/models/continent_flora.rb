class ContinentFlora < ApplicationRecord
  belongs_to :continent
  belongs_to :flora
  belongs_to :user, optional: true
end
