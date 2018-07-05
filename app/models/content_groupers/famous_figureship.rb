class FamousFigureship < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :race
  belongs_to :famous_figure, class_name: 'Character'
end
