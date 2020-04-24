class TownGroup < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :town
  belongs_to :group, optional: true
end
