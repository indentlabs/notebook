class Raceship < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :race
end
