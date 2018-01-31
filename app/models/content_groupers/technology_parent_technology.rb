class TechnologyParentTechnology < ActiveRecord::Base
  belongs_to :user
  belongs_to :technology
  belongs_to :parent_technology, class_name: Technology.name
end
