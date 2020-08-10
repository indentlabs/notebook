class LoreCreatedTradition < ApplicationRecord
  belongs_to :lore
  belongs_to :created_tradition, class_name: Tradition.name, optional: true
  
  belongs_to :user, optional: true
end
