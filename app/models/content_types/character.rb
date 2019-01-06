##
# = char-ac-ter
# == /'kerekter/
# _noun_
#
# 1. a person in a User's story.
#
#    exists within a Universe.
class Character < ApplicationRecord
  acts_as_paranoid

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
  self.authorizer_name = 'CoreContentAuthorizer'

  relates :fathers,          with: :fatherships
  relates :mothers,          with: :motherships
  relates :siblings,         with: :siblingships
  relates :spouses,          with: :marriages
  relates :children,         with: :childrenships
  relates :best_friends,     with: :best_friendships
  relates :archenemies,      with: :archenemyship
  relates :love_interests,   with: :character_love_interests
  relates :birthplaces,      with: :birthings
  relates :races,            with: :raceships
  relates :spoken_languages, with: :lingualisms
  relates :items,            with: :character_items
  relates :technologies,     with: :character_technologies
  relates :floras,           with: :character_floras
  relates :friends,          with: :character_friends
  relates :companions,       with: :character_companions
  relates :birthtowns,       with: :character_birthtowns
  relates :magics,           with: :character_magics
  relates :enemies,          with: :character_enemies

  def description
    overview_field_value('Role')
  end

  def self.content_name
    'character'
  end

  def self.color
    'red'
  end

  def self.hex_color
    '#F44336'
  end

  def self.icon
    'group'
  end
end
