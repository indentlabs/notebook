class ContinentCountry < ApplicationRecord
  belongs_to :continent
  belongs_to :country, optional: true
  belongs_to :user, optional: true
end
