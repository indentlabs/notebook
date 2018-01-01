class TownCreature < ActiveRecord::Base
  belongs_to :user
  belongs_to :town
  belongs_to :creature
end
