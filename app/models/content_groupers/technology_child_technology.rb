class TechnologyChildTechnology < ActiveRecord::Base
  belongs_to :user
  belongs_to :technology
  belongs_to :child_technology, class_name: Technology.name
end
