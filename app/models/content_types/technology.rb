class Technology < ActiveRecord
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include BelongsToUniverse
  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include HasImageUploads
  include HasChangelog
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  relates :characters,           with: :technology_characters
  relates :towns,                with: :technology_towns
  relates :countries,            with: :technology_countries
  relates :groups,               with: :technology_groups
  relates :creatures,            with: :technology_creatures
  relates :planets,              with: :technology_planets
  relates :magics,               with: :technology_magics
  relates :parent_technologies,  with: :technology_parent_technologies
  relates :child_technologies,   with: :technology_child_technologies
  relates :related_technologies, with: :technology_related_technologies

  def self.color
    'text-darken-2 red'
  end

  def self.icon
    'router'
  end

  def self.content_name
    'technology'
  end
end
