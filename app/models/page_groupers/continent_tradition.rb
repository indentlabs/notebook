class ContinentTradition < ApplicationRecord
  belongs_to :continent
  belongs_to :tradition, optional: true
  belongs_to :user, optional: true
end
