class ContinentTradition < ApplicationRecord
  belongs_to :continent
  belongs_to :tradition
  belongs_to :user, optional: true
end
