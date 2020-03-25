class ContinentLanguage < ApplicationRecord
  belongs_to :continent
  belongs_to :language
  belongs_to :user, optional: true
end
