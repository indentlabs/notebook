class Language < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse

  include HasAttributes
  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  def description
    num_speakers = Lingualism.where(spoken_language_id: id).count
    "Language spoken by #{ActionController::Base.helpers.pluralize num_speakers, 'character'}"
  end

  def self.color
    'blue'
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
