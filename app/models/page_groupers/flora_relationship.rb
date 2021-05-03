class FloraRelationship < ApplicationRecord
  include HasContentLinking
  LINK_TYPE = :two_way

  belongs_to :user, optional: true

  belongs_to :flora
  belongs_to :related_flora, class_name: 'Flora', optional: true

  # after_create do
  #   self.reciprocate relation: :flora_relationships, parent_object_ref: :flora, added_object_ref: :related_flora
  # end

  # after_destroy do
  #   # This is a two-way relation, so we should also delete the reverse association
  #   this_object  = Flora.find_by(id: self.flora_id)
  #   other_object = Flora.find_by(id: self.related_flora_id)

  #   other_object.related_floras.delete this_object
  # end
end
