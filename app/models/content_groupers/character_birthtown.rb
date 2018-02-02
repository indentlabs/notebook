class CharacterBirthtown < ActiveRecord::Base
  belongs_to :user
  belongs_to :character
  belongs_to :birthtown, class_name: Town.name
end
