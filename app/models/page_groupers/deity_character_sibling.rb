class DeityCharacterSibling < ApplicationRecord
  include HasContentLinking

  belongs_to :deity
  belongs_to :character_sibling, class_name: Character.name, optional: true
  belongs_to :user, optional: true
end
