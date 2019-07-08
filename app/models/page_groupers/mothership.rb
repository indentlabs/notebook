class Mothership < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :mother, class_name: 'Character'

  after_create do
    this_object  = Character.find_by(id: self.character_id)
    other_object = Character.find_by(id: self.mother_id)

    # If this character is marked as the mother of another character, we should mark that character as a child of this character
    other_object.childrenships.create(character: other_object, child: this_object) unless other_object.children.include?(this_object)
  end

  after_destroy do
    # This is a two-way relation, so we should also delete the reverse association
    this_object  = Character.find_by(id: self.character_id)
    other_object = Character.find_by(id: self.mother_id)

    other_object.children.delete(this_object) if other_object.present?
  end
end
