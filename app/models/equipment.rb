##
# = e-quip-ment
# == /e'kwipment/
# _noun_
#
# 1. the necessary items for a particular purpose.
#
#    exists within a Universe.
class Equipment < ActiveRecord::Base
  include HasPrivacy
  include Comparable
  include NilsBlankUniverse

  validates :name, presence: true

  belongs_to :user
  belongs_to :universe

  def <=>(other)
    name.downcase <=> other.name.downcase
  end
end
