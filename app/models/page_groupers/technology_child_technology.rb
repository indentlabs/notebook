class TechnologyChildTechnology < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true
  belongs_to :technology
  belongs_to :child_technology, class_name: Technology.name, optional: true

  # after_create do
  #   this_object  = Technology.find_by(id: self.technology_id)
  #   other_object = Technology.find_by(id: self.child_technology_id)

  #   other_object.technology_parent_technologies.create(
  #     technology:        other_object,
  #     parent_technology: this_object
  #   ) unless other_object.parent_technologies.include?(this_object)
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Technology.find_by(id: self.technology_id)
  #   other_object = Technology.find_by(id: self.child_technology_id)

  #   other_object.parent_technologies.delete(this_object) if other_object.present?
  # end
end
