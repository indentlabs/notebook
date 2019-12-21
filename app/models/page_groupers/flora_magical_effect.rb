class FloraMagicalEffect < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :flora
  belongs_to :magic, class_name: 'Magic'
end
