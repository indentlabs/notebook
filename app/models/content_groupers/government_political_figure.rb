class GovernmentPoliticalFigure < ActiveRecord::Base
  belongs_to :user
  belongs_to :government
  belongs_to :political_figure, class_name: Character.name
end
