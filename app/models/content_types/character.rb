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

  include HasAttributes
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

  # Races
  relates :races,          with: :raceships

  # Languages
  relates :spoken_languages, with: :lingualisms

  scope :is_public, -> { eager_load(:universe).where('characters.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def description
    role
  end

  def self.content_name
    'character'
  end

  def self.color
    'red'
  end

  def self.icon
    'group'
  end
end
