class Scene < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include HasImageUploads
  include HasChangelog

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'CollectiveContentAuthorizer'

  # Characters
  relates :scene_characters, with: :scene_characterships

  # Locations
  relates :scene_locations, with: :scene_locationships

  # Items
  relates :scene_items, with: :scene_itemships

  scope :is_public, -> { eager_load(:universe).where('scenes.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'grey'
  end

  def self.icon
    'local_movies'
  end

  def self.content_name
    'scene'
  end

  def deleted_at
    nil #hack
  end
end
