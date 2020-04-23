class LoreOriginalLanguage < ApplicationRecord
  belongs_to :lore
  belongs_to :original_language, class_name: Language.name
  
  belongs_to :user, optional: true
end
