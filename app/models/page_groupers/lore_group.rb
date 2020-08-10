class LoreGroup < ApplicationRecord
  belongs_to :lore
  belongs_to :group, optional: true
  
  belongs_to :user, optional: true
end
