class DeityCharacterChild < ActiveRecord::Base
  belongs_to :user
  belongs_to :deity
  belongs_to :character_child, class_name: Character.name
end
