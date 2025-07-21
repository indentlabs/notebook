class TimelineEvent < ApplicationRecord
  acts_as_paranoid

  belongs_to :timeline, touch: true

  has_many :timeline_event_entities, dependent: :destroy

  acts_as_list scope: [:timeline_id]

  # Validations
  validates :event_type, presence: true, inclusion: { in: %w[general plot_event character_development world_event historical battle political cultural mystery research] }
  validates :importance_level, presence: true, inclusion: { in: %w[major minor background] }
  validates :status, presence: true, inclusion: { in: %w[planned happening completed cancelled] }

  # Scopes
  scope :by_type, ->(type) { where(event_type: type) }
  scope :by_importance, ->(level) { where(importance_level: level) }
  scope :by_status, ->(status) { where(status: status) }
  scope :major_events, -> { where(importance_level: 'major') }
  scope :completed_events, -> { where(status: 'completed') }

  # Event type definitions with display info
  EVENT_TYPES = {
    'general' => { name: 'General Event', color: 'gray', icon: 'event' },
    'plot_event' => { name: 'Plot Event', color: 'blue', icon: 'timeline' },
    'character_development' => { name: 'Character Development', color: 'green', icon: 'person' },
    'world_event' => { name: 'World Event', color: 'purple', icon: 'public' },
    'historical' => { name: 'Historical', color: 'amber', icon: 'history' },
    'battle' => { name: 'Battle/Conflict', color: 'red', icon: 'sword' },
    'political' => { name: 'Political', color: 'indigo', icon: 'gavel' },
    'cultural' => { name: 'Cultural', color: 'pink', icon: 'celebration' },
    'mystery' => { name: 'Mystery/Clue', color: 'yellow', icon: 'search' },
    'research' => { name: 'Research Note', color: 'teal', icon: 'book' }
  }.freeze

  IMPORTANCE_LEVELS = {
    'major' => { name: 'Major Event', weight: 3 },
    'minor' => { name: 'Minor Event', weight: 2 },
    'background' => { name: 'Background Detail', weight: 1 }
  }.freeze

  STATUS_OPTIONS = {
    'planned' => { name: 'Planned', color: 'yellow' },
    'happening' => { name: 'Happening', color: 'blue' },
    'completed' => { name: 'Completed', color: 'green' },
    'cancelled' => { name: 'Cancelled', color: 'gray' }
  }.freeze

  # Helper methods
  def event_type_info
    EVENT_TYPES[event_type] || EVENT_TYPES['general']
  end

  def importance_info
    IMPORTANCE_LEVELS[importance_level] || IMPORTANCE_LEVELS['minor']
  end

  def status_info
    STATUS_OPTIONS[status] || STATUS_OPTIONS['completed']
  end

  def has_duration?
    end_time_label.present?
  end

  def display_duration
    return time_label if end_time_label.blank?
    "#{time_label} - #{end_time_label}"
  end

  def color_class
    "timeline-event-#{event_type_info[:color]}"
  end

  def importance_weight
    importance_info[:weight]
  end

  # todo move this to a real permissions authorizer
  def can_be_modified_by?(user)
    user == timeline.user
  end
end
