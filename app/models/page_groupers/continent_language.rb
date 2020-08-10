class ContinentLanguage < ApplicationRecord
  belongs_to :continent
  belongs_to :language, optional: true
  belongs_to :user, optional: true
end
