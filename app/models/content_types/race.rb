##
# = race
# == /'reis/
# _noun_
#
# 1. each of the major divisions of sentient life, having distinct physical characteristics
class Race < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

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
end
