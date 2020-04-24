class LoreTechnology < ApplicationRecord
  belongs_to :lore
  belongs_to :technology, optional: true
  
  belongs_to :user, optional: true
end
