
class Continent < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  validates :user_id, presence: true # belongs_to are no longer optional in rails 6 so we probably don't need this on any content type

  validates :name, presence: true

  include BelongsToUniverse
  include IsContentPage
  
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  def description
    overview_field_value('Description')
  end

  def self.color
    'lighten-1 text-lighten-1 green'
  end

  def self.hex_color
    '#66BB6A'
  end

  def self.icon
    'explore'
  end

  def self.content_name
    'continent'
  end
end
    