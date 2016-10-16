class Scene < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Characters
  # relates :notable_figures, with: :something
  # relates :dieties, with: :something

  # Locations
  # relates :practicing_locations, with: :something

  # Items
  # relates :artifacts, with: :something

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
      # contents: {
      #   icon: 'face',
      #   attributes: %w()
      # },
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
