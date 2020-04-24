class Birthing < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :character
  belongs_to :birthplace, class_name: 'Location', optional: true

  # TODO: more fields here
end
