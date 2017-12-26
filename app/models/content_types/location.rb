##
# = lo-ca-tion
# == /lo'kaSH(e)n/
# _noun_
#
# 1. a particular place or position
#
#    exists within a Universe
class Location < ActiveRecord::Base
  acts_as_paranoid

  has_attached_file :map, styles: { original: '1920x1080>', thumb: '200x200>' }
  validates_attachment_content_type :map, content_type: %r{\Aimage\/.*\Z}

  validates :name, presence: true

  belongs_to :user
  include BelongsToUniverse

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include HasImageUploads
  include HasChangelog

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'CoreContentAuthorizer'

  # Characters
  relates :leaders,           with: :location_leaderships

  # Locations
  relates :capital_cities,    with: :capital_cities_relationships
  relates :largest_cities,    with: :largest_cities_relationships
  relates :notable_cities,    with: :notable_cities_relationships

  # Languages
  relates :languages,         with: :location_languageships

  scope :is_public, -> { eager_load(:universe).where('universes.privacy = ? OR locations.privacy = ?', 'public', 'public') }

  def self.icon
    'terrain'
  end

  def self.color
    'green'
  end

  def self.content_name
    'location'
  end

  def deleted_at
    nil #hack
  end
end
