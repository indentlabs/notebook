##
# = e-quip-ment
# == /e'kwipment/
# _noun_
#
# 1. the necessary items for a particular purpose.
#
#    exists within a Universe.
class Item < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  belongs_to :universe

  def self.color
    'amber'
  end

  def self.icon
    'beach_access'
  end

  def self.attribute_categories
    {
      general_information: {
        icon: 'info',
        attributes: %w(name item_type description universe_id),
      },
      appearance: {
        icon: 'face',
        attributes: %w(weight)
      },
      history: {
        icon: 'face',
        attributes: %w(original_owner current_owner made_by materials year_made)
      },
      abilities: {
        icon: 'face',
        attributes: %w(magic)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
