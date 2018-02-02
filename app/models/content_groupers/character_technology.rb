class CharacterTechnology < ActiveRecord::Base
  belongs_to :user
  belongs_to :character
  belongs_to :technology
end
