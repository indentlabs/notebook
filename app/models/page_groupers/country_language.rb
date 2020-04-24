class CountryLanguage < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :country
  belongs_to :language, optional: true
end
