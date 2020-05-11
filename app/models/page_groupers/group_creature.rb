class GroupCreature < ApplicationRecord
  belongs_to :group
  belongs_to :creature, optional: true
  belongs_to :user, optional: true
end
