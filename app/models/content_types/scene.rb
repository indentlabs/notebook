class Scene < ApplicationRecord
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
  relates :scene_characters, with: :scene_characterships

  # Locations
  relates :scene_locations, with: :scene_locationships

  # Items
  relates :scene_items, with: :scene_itemships

  def description
    overview_field_value('Description')
  end

  def self.color
    'grey'
  end

  def self.hex_color
    '#9E9E9E'
  end

  def self.icon
    'local_movies'
  end

  def self.content_name
    'scene'
  end
end
