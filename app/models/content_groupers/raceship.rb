class Raceship < ActiveRecord::Base
  belongs_to :user

  belongs_to :character
  belongs_to :race
end
