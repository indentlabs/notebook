class School < ActiveRecord::Base
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
    'cyan bg-rose-800'
  end

  def self.text_color
    'cyan-text text-rose-800'
  end

  def self.hex_color
    '#00BCD4'
  end

  def self.icon
    'school'
  end

  def self.content_name
    'school'
  end

  def description
  end
end
    