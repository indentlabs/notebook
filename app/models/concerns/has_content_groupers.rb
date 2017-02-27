require 'active_support/concern'

module HasContentGroupers
  extend ActiveSupport::Concern

  included do
    # Example:
    #   relates :siblings, with: :siblingships
    #   Defines :siblings and :siblingships relations, their inverses, and accepts_nested_attributes for siblingships
    def self.relates relation, with:, where: {}
      singularized_relation = relation.to_s.singularize
      connecting_class      = with.to_s.singularize.camelize.constantize
      connecting_class_name = with

      has_many connecting_class_name

      has_many relation,
        through: connecting_class_name,
        after_add: connecting_class.new.after_add_handler # <--- this calls the after_add defined in the model's concern, instead of the model's one

      accepts_nested_attributes_for connecting_class_name,
        reject_if: :all_blank,
        allow_destroy: true

      has_many "inverse_#{connecting_class_name}".to_sym,
        class_name: "#{singularized_relation.capitalize}",
        foreign_key: "#{singularized_relation}_id"

      has_many "inverse_#{relation}".to_sym,
        through: "inverse_#{connecting_class_name}".to_sym,
        source: name.downcase
    end
  end
end
