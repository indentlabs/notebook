##
# = cree-chur
# == /'krechurr/
# _noun_
#
# 1. an animal, plant, or other wildlife occuring in a user's story
#
#    exists within a Universe.
class Creature < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include HasImageUploads
  include HasChangelog

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  # Locations
  relates :habitats,    with: :wildlifeships

  # Creatures
  relates :related_creatures, with: :creature_relationships

  scope :is_public, -> { eager_load(:universe).where('creatures.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'brown'
  end

  def self.icon
    'pets'
  end

  def self.content_name
    'creature'
  end

  def deleted_at
    nil #hack
  end
end
