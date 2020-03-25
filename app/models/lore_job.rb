class LoreJob < ApplicationRecord
  belongs_to :lore
  belongs_to :job
  belongs_to :user
end
