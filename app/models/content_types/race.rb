##
# = race
# == /'reis/
# _noun_
#
# 1. each of the major divisions of sentient life, having distinct physical characteristics
class Race < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  # Characters
  relates :famous_figures, with: :famous_figureships

  def description
    overview_field_value('Description')
  end

  def self.color
    'darken-2 light-green'
  end

  def self.hex_color
    '#689F38'
  end

  def self.icon
    'face'
  end

  def self.content_name
    'race'
  end
end
