class Timeline < ApplicationRecord
  acts_as_paranoid

  include IsContentPage
  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  validates :user_id, presence: true

  belongs_to :universe, optional: true
  belongs_to :user

  has_many :timeline_events, -> { order(position: :asc) }

  after_create :initialize_first_event

  def self.content_name
    'timeline'
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

  def initialize_first_event
    timeline_events.create(title: "Untitled Event", position: 1)
  end
end
