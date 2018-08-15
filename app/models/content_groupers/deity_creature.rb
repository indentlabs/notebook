class DeityCreature < ApplicationRecord
  belongs_to :user
  belongs_to :deity
  belongs_to :creature
end
