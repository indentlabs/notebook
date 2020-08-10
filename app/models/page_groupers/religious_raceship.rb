class ReligiousRaceship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :religion
  belongs_to :race, optional: true
end
