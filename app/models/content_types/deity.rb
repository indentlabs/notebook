class Deity < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  relates :character_parents,  with: :deity_character_parents
  relates :character_partners, with: :deity_character_partners
  relates :character_children, with: :deity_character_children
  relates :character_siblings, with: :deity_character_siblings
  relates :deity_parents,      with: :deity_deity_parents
  relates :deity_partners,     with: :deity_deity_partners
  relates :deity_children,     with: :deity_deity_children
  relates :deity_siblings,     with: :deity_deity_siblings
  relates :creatures,          with: :deity_creatures
  relates :floras,             with: :deity_floras
  relates :races,              with: :deity_races
  relates :religions,          with: :deity_religions
  relates :relics,             with: :deity_relics
  relates :abilities,          with: :deity_abilities
  relates :related_towns,      with: :deity_related_towns
  relates :related_landmarks,  with: :deity_related_landmarks

  def description
    overview_field_value('Description')
  end

  def self.color
    'text-lighten-4 blue'
  end

  def self.hex_color
    '#BBDEFB'
  end

  def self.icon
    'ac_unit'
  end

  def self.content_name
    'deity'
  end
end
