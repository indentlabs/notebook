class Siblingship < ApplicationRecord
  include HasContentLinking
  LINK_TYPE = :two_way

  belongs_to :user

  belongs_to :character
  belongs_to :sibling, class_name: 'Character'

  after_create do
    self.reciprocate(
      relation:          :siblingships, 
      parent_object_ref: :character, 
      added_object_ref:  :sibling
    )
  end

  after_destroy do
    # This is a two-way relation, so we should also delete the reverse association
    this_object  = Character.find_by(id: self.character_id)
    other_object = Character.find_by(id: self.sibling_id)

    other_object.siblings.delete(this_object) if other_object.present?
  end
end
