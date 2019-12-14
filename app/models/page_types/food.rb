class Food < ActiveRecord::Base
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
    'red'
  end

  def self.hex_color
    '#F44336'
  end

  def self.icon
    'fastfood'
  end

  def self.content_name
    'food'
  end

  def description
  end
end
    