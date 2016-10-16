##
# = u-ni-verse
# == /'yoone,vers/
#
# 1. a particular sphere of activity, interest, or experience
#
#    contains all canonically-related content created by Users
class Universe < ActiveRecord::Base
  include HasPrivacy
  include Serendipitous::Concern

  validates :name, presence: true

  belongs_to :user
  # Core content types
  has_many :characters
  has_many :items
  has_many :locations

  # Extended content types
  has_many :creatures
  has_many :races
  has_many :religions
  has_many :magics
  has_many :languages

  scope :is_public, -> { where(privacy: 'public') }

  def content
    [
      characters, locations, items,
      creatures
    ].flatten
  end

  def content_count
    content.count
  end

  def self.color
    'purple'
  end

  def self.icon
    'vpn_lock'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name description)
      },
      history: {
        icon: 'book',
        attributes: %w(history)
      },
      rules: {
        icon: 'gavel',
        attributes: %w(laws_of_physics magic_system technologies)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      },
      settings: {
        icon: 'build',
        attributes: %w(privacy)
      }
    }
  end
end
