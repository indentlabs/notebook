class TownCitizen < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :town
  belongs_to :citizen, class_name: 'Character', optional: true
end
