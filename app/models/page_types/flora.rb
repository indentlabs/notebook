class Flora < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse

  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  relates :related_floras, with: :flora_relationships
  relates :magics, with: :flora_magical_effects
  relates :locations, with: :flora_locations
  relates :creatures, with: :flora_eaten_by

  def description
    overview_field_value('Description')
  end

  def self.content_name
    'flora'
  end

  def self.color
    'text-lighten-2 lighten-2 teal bg-lime-700'
  end

  def self.text_color
    'text-lighten-2 teal-text text-lime-700'
  end

  def self.hex_color
    '#4DB6AC'
  end

  def self.icon
    'eco'
  end
end
