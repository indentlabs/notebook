class LoreRelatedLore < ApplicationRecord
  belongs_to :lore
  belongs_to :related_lore, class_name: Lore.name

  belongs_to :user, optional: true
end
