class Flora < ActiveRecord::Base
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
  self.authorizer_name = 'CoreContentAuthorizer'
  #self.authorizer_name = 'ExtendedContentAuthorizer'

  def self.content_name
    'flora'
  end

  def self.color
    'teal'
  end

  def self.icon
    'local_florist'
  end
end
