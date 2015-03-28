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

  validates :name, presence: true

  belongs_to :user
  belongs_to :universe

  before_save :nil_blank_universe

  def <=>(other)
    name.downcase <=> other.name.downcase
  end

  def nil_blank_universe
    self.universe = nil if universe.blank?
  end
end
