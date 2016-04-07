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

   def self.attribute_categories
    {
      general_information: {
        icon: 'info',
        attributes: %w(name type_of description universe),
      },
      #todo map
      culture: {
        icon: 'face',
        attributes: %w(population language currency motto)
      },
      cities: {
        icon: 'face',
        attributes: %w(capital largest_city notable_cities)
      },
      geography: {
        icon: 'edit',
        attributes: %w(area crops located_at)
      },
      history: {
      	icon: 'edit',
      	attributes: %w(established_year notable_wars)
      },
      notes: {
      	icon: 'edit',
      	attributes: %w(notes private_notes)
      }
    }
  end
end
