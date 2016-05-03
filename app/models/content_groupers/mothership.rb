class Mothership < ActiveRecord::Base
  belongs_to :user

  belongs_to :character
  belongs_to :mother, :class_name => "Character"
end
