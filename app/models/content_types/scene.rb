class Scene < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Characters
  relates :scene_characters, with: :scene_characterships

  # Locations
  relates :scene_locations, with: :scene_locationships

  # Items
  relates :scene_items, with: :scene_itemships

  scope :is_public, -> { eager_load(:universe).where('creatures.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'silver'
  end

  def self.icon
    'local_movies'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name summary universe_id)
      },
      members: {
        icon: 'face',
        attributes: %w(scene_characters scene_locations scene_items)
      },
      prompts: {
        icon: 'fingerprint',
        attributes: %w(cause description results)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
