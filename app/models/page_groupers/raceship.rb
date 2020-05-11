class Raceship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :character
  belongs_to :race, optional: true
end
