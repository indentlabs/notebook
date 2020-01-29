class ContinentPopularFood < ApplicationRecord
  belongs_to :continent
  belongs_to :popular_food, class_name: Food.name
  belongs_to :user, optional: true
end
