require 'active_support/concern'

module HasContentGroupers
  extend ActiveSupport::Concern

  included do
    @@relations = {}

    # Example:
    #   relates :siblings, with: :siblingships, where: { alive: true }, type: :two_way
    #   Defines :siblings and :siblingships relations, their inverses, and accepts_nested_attributes for siblingships
    def self.relates relation, with:#, where: {}
      singularized_relation = relation.to_s.singularize
      connecting_class      = with.to_s.singularize.camelize.constantize
      connecting_class_name = with

      # Store all added relations on the class model, so we can dynamically fetch them all whenever needed.
      # e.g. Character.class_variable_get(:@@relations) => [:mothers, :fathers, :siblings, ...]
      @@relations[relation] = {              # @@relations[:siblings] = {
        with:          with,                 #   with:          :siblingships,
        related_class: connecting_class      #   related_class: Siblingship
      }                                      # }

      # Siblingships
      has_many connecting_class_name, dependent: :destroy

      # Siblings
      has_many relation,
        through: connecting_class_name

      # inverse_siblingships
      has_many "inverse_#{connecting_class_name}".to_sym,
        class_name: "#{singularized_relation.capitalize}",
        foreign_key: "#{singularized_relation}_id"

      # inverse_siblings
      has_many "inverse_#{relation}".to_sym,
        through: "inverse_#{connecting_class_name}".to_sym,
        source: name.downcase

      accepts_nested_attributes_for connecting_class_name,
        reject_if: :all_blank,
        allow_destroy: true
    end
  end
end
