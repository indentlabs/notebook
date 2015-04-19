##
# = char-ac-ter
# == /'kerekter/
# _noun_
#
# 1. a person in a User's story.
#
#    exists within a Universe.
class Character < ActiveRecord::Base
  include Comparable
  include NilsBlankUniverse

  validates :name, presence: true

  belongs_to :user
  belongs_to :universe

  def <=>(other)
    name.downcase <=> other.name.downcase
  end
end
