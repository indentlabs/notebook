##
# = u-ni-verse
# == /'yoone,vers/
#
# 1. a particular sphere of activity, interest, or experience
#
#    contains all canonically-related content created by Users
class Universe < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  has_many :characters
  has_many :items
  has_many :locations

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
      general_information: {
        icon: 'info',
        attributes: %w(name description)
      },
      history: {
        icon: 'face',
        attributes: %w(history)
      },
      settings: {
        icon: 'face',
        attributes: %w(privacy)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
