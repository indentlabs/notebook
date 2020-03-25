
class Lore < ActiveRecord::Base
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
    'grey'
  end

  def self.hex_color
    '#000000'
  end

  def self.icon
    'book'
  end

  def self.content_name
    'lore'
  end
end
    