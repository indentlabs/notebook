class Landmark < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  relates :nearby_towns, with: :landmark_nearby_towns
  relates :countries, with: :landmark_countries
  relates :floras, with: :landmark_floras
  relates :creatures, with: :landmark_creatures

  def description
    overview_field_value('Description')
  end

  def self.content_name
    'landmark'
  end

  def self.color
    'text-lighten-1 lighten-1 orange'
  end

  def self.hex_color
    '#FFA726'
  end

  def self.icon
    'location_on'
  end
end
