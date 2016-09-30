##
# = u-ni-verse
# == /'yoone,vers/
#
# 1. a particular sphere of activity, interest, or experience
#
#    contains all canonically-related content created by Users
class Universe < ActiveRecord::Base
  include HasPrivacy

  validates :name, presence: true

  belongs_to :user
  has_many :characters
  has_many :items
  has_many :locations

  scope :is_public, -> { where(privacy: "public") }

  def content_count
    [
      characters.length,
      items.length,
      locations.length
    ].sum
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
