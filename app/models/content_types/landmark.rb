class Landmark < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include HasImageUploads
  include HasChangelog

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  scope :is_public, -> { eager_load(:universe).where('landmark.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.content_name
    'landmark'
  end

  def self.color
    'text-lighten-1 lighten-1 orange'
  end

  def self.icon
    'location_on'
  end

  # def deleted_at
  #   nil #hack
  # end
end
