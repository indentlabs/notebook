class BuildingSchool < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true
  belongs_to :building
  belongs_to :district_school, class_name: School.name
end
