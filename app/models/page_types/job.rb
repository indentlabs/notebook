
class Job < ActiveRecord::Base
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
    'text-lighten-1 brown'
  end

  def self.hex_color
    '#795548'
  end

  def self.icon
    'work'
  end

  def self.content_name
    'job'
  end

  def description
    overview_field_value('Description')
  end
end
