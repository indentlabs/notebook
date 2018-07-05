class TownGroup < ActiveRecord
  belongs_to :user
  belongs_to :town
  belongs_to :group
end
