class CountryReligion < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :country
  belongs_to :religion, optional: true
end
