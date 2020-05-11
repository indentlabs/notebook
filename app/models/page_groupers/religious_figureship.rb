class ReligiousFigureship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :religion
  belongs_to :notable_figure, class_name: 'Character', optional: true
end
