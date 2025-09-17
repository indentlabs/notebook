
class Sport < ActiveRecord::Base
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
    'orange bg-orange-300'
  end

  def self.text_color
    'orange-text text-orange-300'
  end

  def self.hex_color
    '#FF9800'
  end

  def self.icon
    'sports_volleyball'
  end

  def self.content_name
    'sport'
  end

  def description
  end
end
    