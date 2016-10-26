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

  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Characters
  relates :famous_figures, with: :famous_figureships

  scope :is_public, -> { eager_load(:universe).where('creatures.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'light-green'
  end

  def self.icon
    'face'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name description other_names universe_id)
      },
      looks: {
        icon: 'face',
        attributes: %w(body_shape skin_colors height weight notable_features variance clothing)
      },
      traits: {
        icon: 'fingerprint',
        attributes: %w(strengths weaknesses)
      },
      culture: {
        icon: 'groups',
        attributes: %w(famous_figures traditions beliefs governments technologies occupations economics favorite_foods)
      },
      history: {
        icon: 'import_contacts',
        attributes: %w(notable_events)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
