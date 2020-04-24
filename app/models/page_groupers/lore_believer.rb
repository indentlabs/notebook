class LoreBeliever < ApplicationRecord
  belongs_to :lore
  belongs_to :believer, class_name: Character.name, optional: true
  
  belongs_to :user, optional: true
end
