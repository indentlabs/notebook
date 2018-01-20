##
# = e-quip-ment
# == /e'kwipment/
# _noun_
#
# 1. the necessary items for a particular purpose.
#
#    exists within a Universe.
class Item < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  include BelongsToUniverse

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include HasImageUploads
  include HasChangelog

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'CoreContentAuthorizer'

  # Characters
  relates :original_owners,           with: :original_ownerships
  relates :past_owners,               with: :past_ownerships
  relates :current_owners,            with: :current_ownerships
  relates :makers,                    with: :maker_relationships

  def self.color
    'amber'
  end

  def self.icon
    'beach_access'
  end

  def self.content_name
    'item'
  end
end
