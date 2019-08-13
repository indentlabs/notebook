class Magic < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = "ExtendedContentAuthorizer"

  # Characters
  relates :deities, with: :magic_deityships

  def description
    overview_field_value('Description')
  end

  def self.color
    'orange'
  end

  def self.hex_color
    '#FF9800'
  end

  def self.icon
    'flash_on'
  end

  def self.content_name
    'magic'
  end
end
