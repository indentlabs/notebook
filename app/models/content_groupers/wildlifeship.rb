class Wildlifeship < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :creature
  belongs_to :habitat, class_name: 'Location'
end
