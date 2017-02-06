class FamousFigureship < ActiveRecord::Base
  belongs_to :user

  belongs_to :race
  belongs_to :famous_figure, class_name: 'Character'
end
