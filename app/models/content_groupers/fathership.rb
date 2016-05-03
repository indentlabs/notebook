class Fathership < ActiveRecord::Base
  belongs_to :user

  belongs_to :character
  belongs_to :father, :class_name => "Character"
end
