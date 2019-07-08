
class Building < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = "ExtendedContentAuthorizer"

  def self.color
    'blue-grey'
  end

  def self.hex_color
    '#607D8B'
  end

  def self.icon
    'business'
  end

  def self.content_name
    'building'
  end

  def description
    overview_field_value('Description')
  end
end
