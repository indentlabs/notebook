class Religion < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Characters
  relates :notable_figures, with: :religious_figureships
  relates :deities, with: :deityships

  # Locations
  relates :practicing_locations, with: :religious_locationships

  # Items
  relates :artifacts, with: :artifactships

  # Races
  relates :races, with: :religious_raceships

  scope :is_public, -> { eager_load(:universe).where('creatures.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'yellow'
  end

  def self.icon
    'brightness_7'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name description other_names universe_id)
      },
      history: {
        icon: 'import_contacts',
        attributes: %w(origin_story notable_figures artifacts)
      },
      beliefs: {
        icon: 'forum',
        attributes: %w(deities teachings prophecies places_of_worship worship_services obligations paradise)
      },
      traditions: {
        icon: 'account_balance',
        attributes: %w(initiation rituals holidays)
      },
      spread: {
        icon: 'location_on',
        attributes: %w(practicing_locations races)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
