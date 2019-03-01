class Town < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse

  include HasAttributes
  include IsContentPage
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  relates :citizens, with: :town_citizens
  relates :floras, with: :town_floras
  relates :creatures, with: :town_creatures
  relates :groups, with: :town_groups
  relates :languages, with: :town_languages
  relates :countries, with: :town_countries
  relates :nearby_landmarks, with: :town_nearby_landmarks

  def description
    overview_field_value('Description')
  end

  def self.content_name
    'town'
  end

  def self.color
    'text-lighten-3 lighten-3 purple'
  end

  def self.hex_color
    '#CE93D8'
  end

  def self.icon
    'location_city'
  end
end
