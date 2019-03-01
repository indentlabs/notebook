class DeityRace < ApplicationRecord
  belongs_to :deity
  belongs_to :race
  belongs_to :user
end
