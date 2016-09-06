##
# = u-ni-verse
# == /'yoone,vers/
#
# 1. a particular sphere of activity, interest, or experience
#
#    contains all canonically-related content created by Users
class Universe < ActiveRecord::Base
  include PragmaticContext::Contextualizable
  validates :name, presence: true

  belongs_to :user
  has_many :characters
  has_many :items
  has_many :locations

  scope :is_public, -> { where(privacy: "public") }

  # Used for JSON-LD generation
  contextualize_as_type 'http://schema.org/CreativeWork'
  contextualize_with_id { |universe| Rails.application.routes.url_helpers.universe_url(universe) }
  contextualize :user, as: 'http://schema.org/author'
  contextualize :user, as: 'http://schema.org/copyrightHolder'
  contextualize :characters, as: 'http://schema.org/character'
  contextualize :items, as: 'http://schema.org/hasPart'
  contextualize :locations, as: 'http://schema.org/hasPart'
  contextualize :name, :as => 'http://schema.org/name'
  contextualize :description, :as => 'http://schema.org/description'

  def content_count
    [
      characters.length,
      items.length,
      locations.length
    ].sum
  end

  def self.color
    'purple'
  end

  def self.icon
    'vpn_lock'
  end

  def self.attribute_categories
    {
      general_information: {
        icon: 'info',
        attributes: %w(name description)
      },
      history: {
        icon: 'face',
        attributes: %w(history)
      },
      settings: {
        icon: 'face',
        attributes: %w(privacy)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
