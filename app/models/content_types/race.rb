##
# = race
# == /'reis/
# _noun_
#
# 1. each of the major divisions of sentient life, having distinct physical characteristics
class Race < ActiveRecord::Base
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
  relates :famous_figures, with: :famous_figureships

  scope :is_public, -> { eager_load(:universe).where('races.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'light-green'
  end

  def self.icon
    'face'
  end

  def self.content_name
    'race'
  end

  def deleted_at
    nil #hack
  end
end
