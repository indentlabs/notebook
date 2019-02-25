
class Condition < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  def self.color
    'text-darken-1 lime'
  end

  def self.hex_color
    '#CDDC39'
  end

  def self.icon
    'bubble_chart'
  end

  def self.content_name
    'condition'
  end

  def description
    overview_field_value('Description')
  end
end
