class TownLanguage < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :town
  belongs_to :language
end
