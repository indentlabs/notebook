class Birthing < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :birthplace, class_name: 'Location'

  # TODO: more fields here
end
