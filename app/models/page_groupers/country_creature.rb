class CountryCreature < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :country
  belongs_to :creature
end
