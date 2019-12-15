class CountryTown < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :country
  belongs_to :town
end
