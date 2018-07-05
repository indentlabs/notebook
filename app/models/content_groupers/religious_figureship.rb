class ReligiousFigureship < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :religion
  belongs_to :notable_figure, class_name: 'Character'
end
