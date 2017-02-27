class Mothership < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :mother, class_name: 'Character'
end
