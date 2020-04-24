class DeityRace < ApplicationRecord
  belongs_to :deity
  belongs_to :race, optional: true
  belongs_to :user, optional: true
end
