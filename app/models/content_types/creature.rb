##
# = cree-chur
# == /'krechurr/
# _noun_
#
# 1. an animal, plant, or other wildlife occuring in a user's story
#
#    exists within a Universe.
class Creature < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Locations
  relates :habitats,    with: :wildlifeships

  scope :is_public, -> { eager_load(:universe).where('creatures.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'brown'
  end

  def self.icon
    'pets'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name description type_of other_names universe_id)
      },
      looks: {
        icon: 'face',
        attributes: %w(color shape size notable_features materials)
      },
      traits: {
        icon: 'fingerprint',
        attributes: %w(aggressiveness attack_method defense_method maximum_speed strengths weaknesses sounds spoils)
      },
      habitat: {
        icon: 'groups',
        attributes: %w(preferred_habitat habitats food_sources migratory_patterns reproduction herd_patterns)
      },
      comparisons: {
        icon: 'info',
        attributes: %w(similar_animals symbolisms)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
