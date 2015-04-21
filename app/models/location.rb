##
# = lo-ca-tion
# == /lo'kaSH(e)n/
# _noun_
#
# 1. a particular place or position
#
#    exists within a Universe
class Location < ActiveRecord::Base
  include NilsBlankUniverse

  has_attached_file :map,  styles: { original: '1920x1080>', thumb: '200x200>' }
  validates_attachment_content_type :map, content_type: %r{\Aimage\/.*\Z}

  validates :name, presence: true

  belongs_to :user
  belongs_to :universe
end
