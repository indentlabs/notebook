class GroupCreature < ActiveRecord::Base
  belongs_to :group
  belongs_to :creature
  belongs_to :user
end
