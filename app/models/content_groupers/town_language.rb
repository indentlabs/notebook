class TownLanguage < ActiveRecord
  belongs_to :user
  belongs_to :town
  belongs_to :language
end
