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

  scope :is_public, -> { joins(:universe).where('universes.privacy = ? OR characters.privacy = ?', 'public', 'public') }

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
      general: {
        icon: 'info',
        attributes: %w(name role gender age universe_id)
      },
      appearance: {
        icon: 'face',
        attributes: %w(weight height haircolor hairstyle facialhair eyecolor race skintone bodytype identmarks)
      },
      social: {
        icon: 'groups',
        attributes: %w(best_friends religion politics prejudices occupation)
      },
      # TODO: remove schema for mannerisms
      history: {
        icon: 'info',
        attributes: %w(birthday birthplaces education background)
      },
      favorites: {
        icon: 'star',
        attributes: %w(fave_color fave_food fave_possession fave_weapon fave_animal)
      },
      relations: {
        icon: 'face',
        attributes: %w(mothers fathers spouses siblings archenemies children)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
