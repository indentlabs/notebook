class Timeline < ApplicationRecord
  include Rails.application.routes.url_helpers

  acts_as_paranoid

  include IsContentPage
  include HasPageTags

  include HasImageUploads
  include BelongsToUniverse

  include Authority::Abilities
  self.authorizer_name = 'TimelineAuthorizer'

  validates :user_id, presence: true
  belongs_to :user

  has_many :timeline_events, -> { order(position: :asc) }, dependent: :destroy

  after_create :initialize_first_event

  def self.content_name
    'timeline'
  end

  def self.color
    'green bg-green-500'
  end

  def self.text_color
    'green-text text-green-500'
  end

  # Needed because we sometimes munge Timelines in with ContentPages :(
  def color
    Timeline.color
  end

  def text_color
    Timeline.text_color
  end

  def self.hex_color
    '#4CAF50'
  end

  def self.icon
    'timeline'
  end

  def icon
    Timeline.icon
  end

  def page_type
    'Timeline'
  end

  def view_path
    timeline_path(self.id)
  end

  def edit_path
    edit_timeline_path(self.id)
  end

  def initialize_first_event
    timeline_events.create(title: "Untitled Event", position: 1)
  end
end
