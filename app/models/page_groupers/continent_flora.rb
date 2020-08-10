class ContinentFlora < ApplicationRecord
  belongs_to :continent
  belongs_to :flora, optional: true
  belongs_to :user, optional: true
end
