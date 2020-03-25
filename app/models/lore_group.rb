class LoreGroup < ApplicationRecord
  belongs_to :lore
  belongs_to :group
  belongs_to :user
end
