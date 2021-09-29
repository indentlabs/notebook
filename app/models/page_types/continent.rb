
class Continent < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  validates :user_id, presence: true # belongs_to are no longer optional in rails 6 so we probably don't need this on any content type

  validates :name, presence: true

  include BelongsToUniverse
  include IsContentPage
  
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  relates :landmarks,     with: :continent_landmarks
  relates :creatures,     with: :continent_creatures
  relates :floras,        with: :continent_floras

  relates :countries,     with: :continent_countries
  relates :languages,     with: :continent_languages
  relates :traditions,    with: :continent_traditions
  relates :governments,   with: :continent_governments
  relates :popular_foods, with: :continent_popular_foods

  def description
    overview_field_value('Description')
  end

  def self.color
    'lighten-1 text-lighten-1 green'
  end

  def self.text_color
    'text-lighten-1 green-text'
  end

  def self.hex_color
    '#66BB6A'
  end

  def self.icon
    'explore'
  end

  def self.content_name
    'continent'
  end
end
    