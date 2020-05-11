class GovernmentPoliticalFigure < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :government
  belongs_to :political_figure, class_name: Character.name, optional: true
end
