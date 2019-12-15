class DeityCreature < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :creature
end
