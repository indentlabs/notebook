##
# = e-quip-ment
# == /e'kwipment/
# _noun_
#
# 1. the necessary items for a particular purpose.
#
#    exists within a Universe.
class Item < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  include BelongsToUniverse
  include IsContentPage
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'CoreContentAuthorizer'

  # Characters
  relates :original_owners,           with: :original_ownerships
  relates :past_owners,               with: :past_ownerships
  relates :current_owners,            with: :current_ownerships
  relates :makers,                    with: :maker_relationships
  relates :magics,                    with: :item_magics

  def description
    overview_field_value('Description')
  end

  def self.color
    'text-darken-2 amber'
  end

  def self.text_color
    'text-darken-2 amber-text'
  end

  def self.hex_color
    '#FFA000'
  end

  def self.icon
    'emoji_events'
  end

  def self.content_name
    'item'
  end
end
