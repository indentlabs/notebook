##
# = mag-ic
# == /'majik/
# _noun_
#
# 1. the power of apparently influencing the course of events by using
#    mysterious or supernatural forces.
#
#    used within a universe
#
#    "do you believe in magic?"
class Magic < ActiveRecord::Base
  include NilsBlankUniverse

  validates :name, presence: true

  belongs_to :user
  belongs_to :universe
end
