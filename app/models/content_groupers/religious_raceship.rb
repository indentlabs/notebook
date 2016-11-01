class ReligiousRaceship < ActiveRecord::Base
  belongs_to :user

  belongs_to :religion
  belongs_to :race
end