class CustomPage < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage

  include Authority::Abilities
  self.authorizer_name = 'CoreContentAuthorizer' # CustomContentAuthorizer

  def self.color
    'black'
  end

  def self.icon
    'info'
  end

  def self.content_name
    'custom_page'
  end

  def self.hex_color
    '#000000'
  end

  def description
    "Custom page description"
  end
end
