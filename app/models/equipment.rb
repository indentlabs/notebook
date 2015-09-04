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
  include NilsBlankUniverse

  validates :name, presence: true

  belongs_to :user
  belongs_to :universe

  def <=>(other)
    name.downcase <=> other.name.downcase
  end

  def table_columns
    {
      'Name' => -> { link_to name, self },
      'Type' => equip_type,
      'Description' => description
    }
  end
end
