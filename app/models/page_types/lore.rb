
class Lore < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage
  
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = ExtendedContentAuthorizer.name

  relates :planets, with: :lore_planets
  relates :countries, with: :lore_countries
  relates :continents, with: :lore_continents
  relates :landmarks, with: :lore_landmarks
  relates :towns, with: :lore_towns
  relates :buildings, with: :lore_buildings
  relates :schools, with: :lore_schools
  relates :characters, with: :lore_characters
  relates :deities, with: :lore_deities
  relates :creatures, with: :lore_creatures
  relates :floras, with: :lore_floras
  relates :jobs, with: :lore_jobs
  relates :technologies, with: :lore_technologies
  relates :vehicles, with: :lore_vehicles
  relates :conditions, with: :lore_conditions
  relates :races, with: :lore_races
  relates :religions, with: :lore_religions
  relates :magics, with: :lore_magics
  relates :governments, with: :lore_governments
  relates :groups, with: :lore_groups
  relates :traditions, with: :lore_traditions
  relates :foods, with: :lore_foods
  relates :sports, with: :lore_sports
  relates :believers, with: :lore_believers
  relates :created_traditions, with: :lore_created_traditions
  relates :original_languages, with: :lore_original_languages
  relates :variations, with: :lore_variations
  relates :related_lores, with: :lore_related_lores

  def self.color
    'text-lighten-2 lighten-1 orange'
  end

  def self.text_color
    'text-lighten-2 orange-text'
  end

  def self.hex_color
    '#FFB74D'
  end

  def self.icon
    'book'
  end

  def self.content_name
    'lore'
  end

  def description
    overview_field_value('Summary')
  end
end
    