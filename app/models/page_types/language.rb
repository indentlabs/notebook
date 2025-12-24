class Language < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse

  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  def description
    overview_field_value('Description')
  end

  def self.color
    'blue bg-cyan-700'
  end

  def self.text_color
    'blue-text text-cyan-700'
  end

  def self.hex_color
    '#2196F3'
  end

  def self.icon
    'forum'
  end

  def self.content_name
    'language'
  end
end
