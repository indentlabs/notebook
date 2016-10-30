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

  scope :is_public, -> { eager_load(:universe).where('magics.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'orange'
  end

  def self.icon
    'flash_on'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name description type_of universe_id)
      },
      appearance: {
        icon: 'flash_on',
        attributes: %w(visuals effects)
      },
      effects: {
        icon: 'flare',
        attributes: %w(positive_effects negative_effects neutral_effects)
      },
      alignment: {
        icon: 'polymer',
        attributes: %w(element deities)
      },
      requirements: {
        icon: 'lock',
        attributes: %w(resource_costs materials skills_required limitations)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
