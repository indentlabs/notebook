##
# = u-ni-verse
# == /'yoone,vers/
#
# 1. a particular sphere of activity, interest, or experience
#
#    contains all canonically-related content created by Users
class Universe < ActiveRecord::Base

  include HasAttributes
  include HasPrivacy
  include Serendipitous::Concern

  validates :name, presence: true

  belongs_to :user
  has_many :characters
  has_many :items
  has_many :locations

  scope :is_public, -> { where(privacy: 'public') }

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

  def self.content_name
    'universe'
  end
end
