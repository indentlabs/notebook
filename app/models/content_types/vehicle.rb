
class Vehicle < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include IsContentPage
  include BelongsToUniverse
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  def self.color
    'text-lighten-2 green'
  end

  def self.hex_color
    '#81C784'
  end

  def self.icon
    'drive_eta'
  end

  def self.content_name
    'vehicle'
  end

  def description
    overview_field_value('Description')
  end
end
