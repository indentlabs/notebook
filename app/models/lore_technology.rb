class LoreTechnology < ApplicationRecord
  belongs_to :lore
  belongs_to :technology
  belongs_to :user
end
