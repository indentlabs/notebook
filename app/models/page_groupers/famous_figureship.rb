class FamousFigureship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :race
  belongs_to :famous_figure, class_name: 'Character'
end
