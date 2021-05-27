class TechnologyRelatedTechnology < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true
  belongs_to :technology
  belongs_to :related_technology, class_name: Technology.name, optional: true

  # after_create do
  #   self.reciprocate relation: :technology_related_technologies, parent_object_ref: :technology, added_object_ref: :related_technology
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Technology.find_by(id: self.technology_id)
  #   other_object = Technology.find_by(id: self.related_technology_id)

  #   other_object.related_technologies.delete(this_object) if other_object.present?
  # end
end
