class Planet < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  relates :countries,      with: :planet_countries
  relates :locations,      with: :planet_locations
  relates :landmarks,      with: :planet_landmarks
  relates :races,          with: :planet_races
  relates :floras,         with: :planet_floras
  relates :creatures,      with: :planet_creatures
  relates :religions,      with: :planet_religions
  relates :deities,        with: :planet_deities
  relates :groups,         with: :planet_groups
  relates :languages,      with: :planet_languages
  relates :towns,          with: :planet_towns
  relates :nearby_planets, with: :planet_nearby_planets

  def description
    overview_field_value('Description')
  end

  def self.color
    'text-lighten-2 blue'
  end

  def self.hex_color
    '#64B5F6'
  end

  def self.icon
    'public'
  end

  def self.content_name
    'planet'
  end
end
