##
# = cree-chur
# == /'krechurr/
# _noun_
#
# 1. an animal, plant, or other wildlife occuring in a user's story
#
#    exists within a Universe.
class Creature < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  # Locations
  relates :habitats,    with: :wildlifeships

  # Creatures
  relates :related_creatures, with: :creature_relationships

  def description
    overview_field_value('Description')
  end

  def self.color
    'brown'
  end

  def self.hex_color
    '#795548'
  end

  def self.icon
    'pets'
  end

  def self.content_name
    'creature'
  end
end
