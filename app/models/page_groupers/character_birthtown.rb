class CharacterBirthtown < ApplicationRecord
  belongs_to :user, optional: true

  belongs_to :character
  belongs_to :birthtown, class_name: Town.name, optional: true
end
