require 'active_support/concern'

# DEPRECATED :)
module HasContentGroupers
  extend ActiveSupport::Concern

  included do
    # Example:
    #   relates :siblings, with: :siblingships, where: { alive: true }, type: :two_way
    #   Defines :siblings and :siblingships relations, their inverses, and accepts_nested_attributes for siblingships
    def self.relates relation, with:#, where: {}
      singularized_relation = relation.to_s.singularize
      connecting_class      = with.to_s.singularize.camelize.constantize
      connecting_class_name = with

      if relation == :deity_characters
        # sadface, SADFACE
        singularized_relation = :deity
      end

      # Fetch the connecting class's through class (e.g. Character for sibling_id).
      # If there isn't one defined, it means it already maps to a model (e.g. race_id),
      # so we can use the name as the class as well.
      belongs_to_relations = connecting_class.reflect_on_all_associations(:belongs_to)
      through_relation = belongs_to_relations.detect do |relation| # sibling
        # sadface
        if relation.name == :deity_character && singularized_relation == :deity
          true
        else
          relation.name.to_s == singularized_relation
        end
      end
      if through_relation.options.key?(:class_name)
        through_relation_class = through_relation.options[:class_name] # Character
      else
        through_relation_class = through_relation.name.to_s.titleize # Character
      end

      # Store all added relations on the config object, so we can dynamically
      # fetch them all whenever needed. These are used to find all relations
      # where a particular page is the target of a content_grouper, rather than
      # the parent (e.g. one of its has_many's).
      Rails.application.config.content_relations[through_relation_class] ||= {}
      Rails.application.config.content_relations[through_relation_class][connecting_class.name] = \
        {                                         # ['Character'][:siblings] = {
          with:          with,                    #   with:          :siblingships,
          related_class: connecting_class,        #   related_class: Siblingship,
          inverse_class: name,                    #   inverse_class: 'Character',
          relation_text: singularized_relation,   #   relation_text: "Sibling"
          through_relation: singularized_relation #   through_relation: 'Sibling'
        }                                         # }
      
      # The same thing but keyed off inverse class, instead of linked class
      # e.g. Character has raceships (Character -> Race) instead of Race having raceships
      Rails.application.config.inverse_content_relations[name] ||= {}
      Rails.application.config.inverse_content_relations[name][connecting_class.name] = \
        {                                         # ['Character'][:siblings] = {
          with:          with,                    #   with:          :siblingships,
          related_class: connecting_class,        #   related_class: Siblingship,
          inverse_class: name,                    #   inverse_class: 'Character',
          relation_text: singularized_relation,   #   relation_text: "Sibling"
          through_relation: singularized_relation #   through_relation: 'Sibling'
        }                                         # }


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
