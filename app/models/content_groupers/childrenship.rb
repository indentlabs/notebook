class Childrenship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :child, class_name: 'Character'
end
