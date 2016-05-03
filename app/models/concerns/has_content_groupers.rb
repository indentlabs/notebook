require 'active_support/concern'

module HasContentGroupers
  extend ActiveSupport::Concern

  included do
    # relates :siblings, with: :siblingships
    # Defines :siblings and :siblingships relations, their inverses, and accepts nested attributes for the connecting class
    def self.relates relation, with: nil
      singularized_relation = relation.to_s.singularize
      connecting_class = with

      has_many connecting_class
      has_many relation, through: connecting_class
      accepts_nested_attributes_for connecting_class, reject_if: :all_blank, allow_destroy: true
      has_many "inverse_#{connecting_class}".to_sym, class_name: "#{singularized_relation.capitalize}", foreign_key: "#{singularized_relation}_id"
      has_many "inverse_#{relation}".to_sym, through: "inverse_#{connecting_class}".to_sym, source: :character
    end
  end
end