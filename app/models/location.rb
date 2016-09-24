##
# = lo-ca-tion
# == /lo'kaSH(e)n/
# _noun_
#
# 1. a particular place or position
#
#    exists within a Universe
class Location < ActiveRecord::Base
  has_attached_file :map, styles: { original: '1920x1080>', thumb: '200x200>' }
  validates_attachment_content_type :map, content_type: %r{\Aimage\/.*\Z}

  validates :name, presence: true

  belongs_to :user
  belongs_to :universe

  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Characters
  relates :leaders,           with: :location_leaderships

  # Locations
  relates :capital_cities,    with: :capital_cities_relationships
  relates :largest_cities,    with: :largest_cities_relationships
  relates :notable_cities,    with: :notable_cities_relationships

    scope :is_public, -> { joins(:universe).where('universes.privacy = ? OR locations.privacy = ?', 'public', 'public') }

  def self.icon
    'terrain'
  end

  def self.color
    'green'
  end

  def self.attribute_categories
    {
      general_information: {
        icon: 'info',
        attributes: %w(name type_of description universe_id)
      },
      # TODO: map
      culture: {
        icon: 'face',
        attributes: %w(leaders population language currency motto)
      },
      cities: {
        icon: 'face',
        attributes: %w(capital_cities largest_cities notable_cities)
      },
      geography: {
        icon: 'edit',
        attributes: %w(area crops located_at)
      },
      history: {
        icon: 'edit',
        attributes: %w(established_year notable_wars)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
