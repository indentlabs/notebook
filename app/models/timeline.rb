class Timeline < ApplicationRecord
  acts_as_paranoid

  include IsContentPage
  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  belongs_to :universe, optional: true
  belongs_to :user

  has_many :timeline_events

  validates :user_id, presence: true

  def self.content_name
    'timeline'
  end

  def description
    'A timeline'
  end

  def self.color
    'green'
  end

  def self.hex_color
    '#4CAF50'
  end

  def self.icon
    'timeline'
  end
end
