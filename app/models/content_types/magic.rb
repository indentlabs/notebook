class Magic < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Characters
  relates :deities, with: :magic_deityships

  scope :is_public, -> { eager_load(:universe).where('creatures.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'orange'
  end

  def self.icon
    'flare'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name description type_of universe_id)
      },
      appearance: {
        icon: 'face',
        attributes: %w(visuals effects)
      },
      effects: {
        icon: 'fingerprint',
        attributes: %w(positive_effects negative_effects neutral_effects)
      },
      alignment: {
        icon: 'groups',
        attributes: %w(element deities)
      },
      requirements: {
        icon: 'info',
        attributes: %w(resource_costs materials skills_required limitations)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
