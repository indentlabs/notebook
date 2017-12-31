class Country < ActiveRecord::Base
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

  scope :is_public, -> { eager_load(:universe).where('countries.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.content_name
    'country'
  end

  def self.color
    'lighten-2 text-lighten-2 brown'
  end

  def self.icon
    'explore'
  end

  # def deleted_at
  #   nil #hack
  # end
end
