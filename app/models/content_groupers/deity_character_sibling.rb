class DeityCharacterSibling < ApplicationRecord
  include HasContentLinking

  belongs_to :deity
  belongs_to :character_sibling, class_name: Character.name
  belongs_to :user
end
