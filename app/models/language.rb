##
# = lang-guage
# == /'laNGgqwij/
# _noun_
#
# 1. the method of communication, either spoken or written, consisting of the
#    use of words in a structured and conventional way.
#
#    spoken within a Universe
class Language < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  belongs_to :universe
end
