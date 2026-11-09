class TimelineEvent < ApplicationRecord
  acts_as_paranoid

  belongs_to :timeline, touch: true

  has_many :timeline_event_entities, dependent: :destroy
  has_many :word_count_updates, as: :entity

  include HasPageTags

  acts_as_list scope: [:timeline_id]
  attr_accessor :skip_word_count_update

  # Events don't have their own edit page; they're edited on their timeline.
  def edit_path
    timeline&.edit_path
  end

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

  # Track word count changes for title and description fields
  WORD_COUNT_TRACKED_FIELDS = %w[title description].freeze

  after_commit :enqueue_word_count_update, if: :word_count_fields_changed?

  def word_count_fields_changed?
    (saved_changes.keys & WORD_COUNT_TRACKED_FIELDS).any?
  end

  def enqueue_word_count_update
    # Skip enqueueing a job if explicitly flagged (like during timeline initialization)
    return if skip_word_count_update

    # The counts from before and after this edit. The job records exactly these, so two edits
    # queued either side of midnight each count on their own day, once.
    previous_word_count = self.class.word_count_of(
      *WORD_COUNT_TRACKED_FIELDS.map { |field| attribute_before_last_save(field) }
    )
    word_count = self.class.word_count_of(*WORD_COUNT_TRACKED_FIELDS.map { |field| public_send(field) })
    CacheTimelineEventWordCountJob.perform_later(self.id, previous_word_count, word_count)
  end

  def self.word_count_of(*texts)
    texts.sum { |text| WordCountService.count_with_fallback(text) }
  end

  # Helper methods
  def event_type_info
    EVENT_TYPES[event_type] || EVENT_TYPES['general']
  end

  def name
    title
  end

  def event_type_icon
    event_type_info[:icon]
  end

  def event_type_name
    event_type_info[:name]
  end

  def event_type_color
    colors = {
      'general' => 'bg-gray-500',
      'setup' => 'bg-blue-500',
      'exposition' => 'bg-indigo-500',
      'inciting_incident' => 'bg-yellow-500',
      'complication' => 'bg-orange-500',
      'obstacle' => 'bg-red-400',
      'conflict' => 'bg-red-600',
      'progress' => 'bg-green-500',
      'revelation' => 'bg-purple-500',
      'transformation' => 'bg-pink-500',
      'climax' => 'bg-rose-600',
      'resolution' => 'bg-emerald-500',
      'aftermath' => 'bg-cyan-500'
    }
    colors[event_type] || colors['general']
  end

  def has_duration?
    end_time_label.present?
  end

  def display_duration
    return time_label if end_time_label.blank?
    "#{time_label} - #{end_time_label}"
  end

  def can_be_modified_by?(user)
    timeline.updatable_by?(user)
  end
end
