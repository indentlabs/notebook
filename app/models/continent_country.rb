class ContinentCountry < ApplicationRecord
  belongs_to :continent
  belongs_to :country
  belongs_to :user, optional: true
end
