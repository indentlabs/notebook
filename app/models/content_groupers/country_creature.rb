class CountryCreature < ApplicationRecord
  belongs_to :user
  belongs_to :country
  belongs_to :creature
end
