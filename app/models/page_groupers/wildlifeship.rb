class Wildlifeship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :creature
  belongs_to :habitat, class_name: 'Location', optional: true
end
