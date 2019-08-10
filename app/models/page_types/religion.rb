class Religion < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  # Characters
  relates :notable_figures, with: :religious_figureships
  relates :deity_characters, with: :deityships

  # Locations
  relates :practicing_locations, with: :religious_locationships

  # Items
  relates :artifacts, with: :artifactships

  # Races
  relates :races, with: :religious_raceships

  # Deities
  relates :deities, with: :religion_deities

  def description
    overview_field_value('Description')
  end

  def self.color
    'indigo'
  end

  def self.hex_color
    '#3f51b5'
  end

  def self.icon
    'brightness_7'
  end

  def self.content_name
    'religion'
  end
end
