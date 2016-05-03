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

  # TODO: Rip all this out into a HasSiblings concern (or better yet, generalize it into a HasRelationship concern)
  has_many :siblingships
  has_many :siblings, through: :siblingships
  accepts_nested_attributes_for :siblingships, reject_if: :all_blank, allow_destroy: true
  has_many :inverse_siblingships, class_name: 'Siblingship', foreign_key: 'sibling_id'
  has_many :inverse_siblings, through: :inverse_siblingships, source: :character

  # Fathership
  has_many :fatherships
  has_many :fathers, through: :fatherships
  accepts_nested_attributes_for :fatherships, reject_if: :all_blank, allow_destroy: true
  has_many :inverse_fatherships, class_name: 'Fathership', foreign_key: 'father_id'
  has_many :inverse_fathers, through: :inverse_fatherships, source: :character

  # TODO: design DSL in concern to condense these 5-line blocks into 1
  # Mothership
  has_many :motherships
  has_many :mothers, through: :motherships
  accepts_nested_attributes_for :motherships, reject_if: :all_blank, allow_destroy: true
  has_many :inverse_motherships, class_name: 'Mothership', foreign_key: 'mother_id'
  has_many :inverse_mothers, through: :inverse_motherships, source: :character




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
        attributes: %w(name role gender age universe_id),
      },
      appearance: {
        icon: 'face',
        attributes: %w(weight height haircolor hairstyle facialhair eyecolor race skintone bodytype identmarks)
      },
      social: {
        icon: 'groups',
        attributes: %w(bestfriend religion politics prejudices occupation)
      },
      # TODO: remove schema for mannerisms
      history: {
        icon: 'info',
        attributes: %w(birthday birthplace education background)
      },
      favorites: {
        icon: 'star',
        attributes: %w(fave_color fave_food fave_possession fave_weapon fave_animal)
      },
      relations: {
        icon: 'face',
        attributes: %w(mothers fathers spouse siblings archenemy)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
