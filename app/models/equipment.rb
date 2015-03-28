##
# = e-quip-ment
# == /e'kwipment/
# _noun_
#
# 1. the necessary items for a particular purpose.
#
#    exists within a Universe.
class Equipment < ActiveRecord::Base
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
