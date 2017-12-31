##
# = u-ni-verse
# == /'yoone,vers/
#
# 1. a particular sphere of activity, interest, or experience
#
#    contains all canonically-related content created by Users
class Universe < ActiveRecord::Base
  acts_as_paranoid

  include HasAttributes
  include HasPrivacy
  include HasImageUploads
  include HasChangelog

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'UniverseCoreContentAuthorizer'

  validates :name, presence: true
  validates :user_id, presence: true

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
  has_many :floras
  has_many :towns
  has_many :countries
  has_many :landmarks

  has_many :scenes
  has_many :groups

  has_many :contributors, dependent: :destroy

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
    'public'
  end

  def self.content_name
    'universe'
  end

  def deleted_at
    nil #hack
  end
end
