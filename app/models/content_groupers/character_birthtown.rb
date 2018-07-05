class CharacterBirthtown < ActiveRecord
  belongs_to :user
  belongs_to :character
  belongs_to :birthtown, class_name: Town.name
end
