##
# = char-ac-ter
# == /'kerekter/
# _noun_
#
# 1. a person in a User's story.
#
#    exists within a Universe.
class Character < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Characters
  relates :fathers,        with: :fatherships
  relates :mothers,        with: :motherships
  relates :siblings,       with: :siblingships
  relates :spouses,        with: :marriages
  relates :children,       with: :childrenships
  relates :best_friends,   with: :best_friendships
  relates :archenemies,    with: :archenemyship

  # Locations
  relates :birthplaces,    with: :birthings

  # Items
  relates :favorite_items, with: :ownerships, where: { favorite: true }

  scope :is_public, -> { eager_load(:universe).where('characters.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def description
    role
  end

  def self.color
    'red'
  end

  def self.icon
    'group'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name role gender age archetype aliases universe_id)
      },
      looks: {
        icon: 'face',
        attributes: %w(weight height haircolor hairstyle facialhair eyecolor race skintone bodytype identmarks)
      },
      nature: {
        icon: 'fingerprint',
        attributes: %w(mannerisms motivations flaws prejudices talents hobbies personality_type)
      },
      social: {
        icon: 'groups',
        attributes: %w(best_friends archenemies religion politics occupation fave_color fave_food fave_possession fave_weapon fave_animal)
      },
      history: {
        icon: 'info',
        attributes: %w(birthday birthplaces education background)
      },
      family: {
        icon: 'device_hub',
        attributes: %w(mothers fathers spouses siblings children)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
