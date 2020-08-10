class LoreJob < ApplicationRecord
  belongs_to :lore
  belongs_to :job, optional: true
  
  belongs_to :user, optional: true
end
