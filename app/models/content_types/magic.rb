class Magic < ApplicationRecord
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

  # Characters
  relates :deities, with: :magic_deityships

  def self.color
    'orange'
  end

  def self.icon
    'flash_on'
  end

  def self.content_name
    'magic'
  end
end
