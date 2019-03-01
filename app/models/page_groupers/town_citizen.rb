class TownCitizen < ApplicationRecord
  belongs_to :user
  belongs_to :town
  belongs_to :citizen, class_name: 'Character'
end
