class CountryReligion < ActiveRecord
  belongs_to :user
  belongs_to :country
  belongs_to :religion
end
