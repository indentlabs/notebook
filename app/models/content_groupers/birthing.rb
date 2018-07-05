class Birthing < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :birthplace, class_name: 'Location'

  # TODO: more fields here
end
