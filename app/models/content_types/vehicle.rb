
class Vehicle < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
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

  def self.color
    'brown'
  end

  def self.icon
    'info'
  end

  def self.content_name
    'vehicle'
  end
end
