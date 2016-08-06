class Childrenship < ActiveRecord::Base
  belongs_to :user

  belongs_to :character
  belongs_to :child, :class_name => "Character"
end
