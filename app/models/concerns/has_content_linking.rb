require 'active_support/concern'

module HasContentLinking
  extend ActiveSupport::Concern

  # Default linking to one-way. All possible values:
  #  - :one_way
  #  - :two_way
  LINK_TYPE = :one_way

  included do
    def reciprocate relation:, parent_object_ref:, added_object_ref:
      parent_object = self.send(parent_object_ref)
      added_object  = self.send(added_object_ref)

      # if some_character.siblingships.pluck(:sibling_id).include?(parent_object.id)
      if added_object.send(relation).pluck("#{added_object_ref}_id").include?(parent_object.id)
        # Two-way relation already exists
      else
        # If a two-way relation doesn't already exist, create it
        added_object.send(relation) << relation.to_s.singularize.camelize.constantize.create({
          "#{parent_object_ref}": added_object,   # character: sibling
          "#{added_object_ref}":  parent_object   # sibling:   character
        })
        #added_object.save
      end
    end
  end
end
