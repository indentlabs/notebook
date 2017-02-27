class ReligiousRaceship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :religion
  belongs_to :race
end