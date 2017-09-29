class FloraMagicalEffect < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :flora
  belongs_to :magic, class_name: 'Magic'
end
