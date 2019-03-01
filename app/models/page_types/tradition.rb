
class Tradition < ActiveRecord::Base
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
    'text-lighten-3 lighten-3 red'
  end

  def self.hex_color
    '#EF9A9A'
  end

  def self.icon
    'today'
  end

  def self.content_name
    'tradition'
  end

  def description
    overview_field_value('Description')
  end
end
