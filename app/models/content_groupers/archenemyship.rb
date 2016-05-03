class Archenemyship < ActiveRecord::Base
  belongs_to :user

  belongs_to :character
  belongs_to :archenemy, :class_name => "Character"
end
