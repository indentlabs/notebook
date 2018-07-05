class CountryTown < ApplicationRecord
  belongs_to :user
  belongs_to :country
  belongs_to :town
end
