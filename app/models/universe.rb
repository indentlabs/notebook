##
# = u-ni-verse
# == /'yoone,vers/
#
# 1. a particular sphere of activity, interest, or experience
#
#    contains all canonically-related content created by Users
class Universe < ActiveRecord::Base
  include HasPrivacy

  validates :name, presence: true

  belongs_to :user
  has_many :characters
  has_many :equipment
  has_many :languages
  has_many :locations
  has_many :magics

  def content_count
    [
      characters.length,
      equipment.length,
      languages.length,
      locations.length,
      magics.length
    ].sum
  end
end
