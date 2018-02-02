class DeityCharacterParent < ActiveRecord::Base
  belongs_to :user
  belongs_to :deity
  belongs_to :character_parent, class_name: Character.name
end
