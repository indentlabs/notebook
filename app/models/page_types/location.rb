##
# = lo-ca-tion
# == /lo'kaSH(e)n/
# _noun_
#
# 1. a particular place or position
#
#    exists within a Universe
class Location < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  include BelongsToUniverse
  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'CoreContentAuthorizer'

  relates :leaders,           with: :location_leaderships
  relates :capital_cities,    with: :capital_cities_relationships
  relates :largest_cities,    with: :largest_cities_relationships
  relates :notable_cities,    with: :notable_cities_relationships
  relates :languages,         with: :location_languageships
  relates :capital_towns,     with: :location_capital_towns
  relates :largest_towns,     with: :location_largest_towns
  relates :notable_towns,     with: :location_notable_towns
  relates :landmarks,         with: :location_landmarks

  def description
    overview_field_value('Description')
  end

  def self.icon
    'terrain'
  end

  def self.color
    'green bg-green-500'
  end

  def self.text_color
    'green-text text-green-500'
  end

  def self.hex_color
    '#4CAF50'
  end

  def self.content_name
    'location'
  end
end
