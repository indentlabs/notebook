class Group < ActiveRecord::Base
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
    'cyan'
  end

  def self.icon
    'wc'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name description other_names universe_id)
      },
      hierarchy: {
        icon: 'face',
        attributes: %w(organization_structure)
      },
      purpose: {
        icon: 'fingerprint',
        attributes: %w(motivation goal obstacles risks)
      },
      inventory: {
        icon: 'groups',
        attributes: %w(inventory)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
