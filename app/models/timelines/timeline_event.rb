class TimelineEvent < ApplicationRecord
  acts_as_paranoid

  belongs_to :timeline, touch: true

  has_many :timeline_event_entities, dependent: :destroy
  
  include HasPageTags

  acts_as_list scope: [:timeline_id]

  # Event type definitions with narrative focus and Material Icons
  EVENT_TYPES = {
    'general' => { name: 'General', icon: 'radio_button_checked' },
    'setup' => { name: 'Setup', icon: 'foundation' },
    'exposition' => { name: 'Exposition', icon: 'info' },
    'inciting_incident' => { name: 'Inciting Incident', icon: 'flash_on' },
    'complication' => { name: 'Complication', icon: 'warning' },
    'obstacle' => { name: 'Obstacle', icon: 'block' },
    'conflict' => { name: 'Conflict', icon: 'gavel' },
    'progress' => { name: 'Progress', icon: 'trending_up' },
    'revelation' => { name: 'Revelation', icon: 'visibility' },
    'transformation' => { name: 'Transformation', icon: 'autorenew' },
    'climax' => { name: 'Climax', icon: 'whatshot' },
    'resolution' => { name: 'Resolution', icon: 'check_circle' },
    'aftermath' => { name: 'Aftermath', icon: 'restore' }
  }.freeze

  # Validation
  validates :event_type, inclusion: { in: EVENT_TYPES.keys }

  # Helper methods
  def event_type_info
    EVENT_TYPES[event_type] || EVENT_TYPES['general']
  end

  def event_type_icon
    event_type_info[:icon]
  end

  def event_type_name
    event_type_info[:name]
  end

  def has_duration?
    end_time_label.present?
  end

  def display_duration
    return time_label if end_time_label.blank?
    "#{time_label} - #{end_time_label}"
  end

  # todo move this to a real permissions authorizer
  def can_be_modified_by?(user)
    user == timeline.user
  end
end
