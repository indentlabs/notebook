class TechnologyRelatedTechnology < ActiveRecord::Base
  belongs_to :user
  belongs_to :technology
  belongs_to :related_technology, class_name: Technology.name
end
