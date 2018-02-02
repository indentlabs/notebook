class TechnologyCreature < ActiveRecord::Base
  belongs_to :user
  belongs_to :technology
  belongs_to :creature
end
