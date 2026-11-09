# One row per tracked entity (document, notebook page, timeline event, book) per day it was edited,
# plus "ManualAdjustment" rows that writers add by hand.
#
# - word_count is the entity's whole word count at the end of for_date. For a manual adjustment it
#   is the number of words being added (or removed, if negative).
# - starting_word_count is the entity's count when the first change of for_date was saved, measured
#   the same way. Rows from before that column existed have none; their day starts from the
#   entity's previous row instead.
#
# Words written on a day are each row's word_count minus the count its day started from. Deletions
# don't subtract (a day that removed more than it added counts as 0), except in manual adjustments.
class WordCountUpdate < ApplicationRecord
  MANUAL_ADJUSTMENT = 'ManualAdjustment'.freeze
  MAX_RETRY_ATTEMPTS = 3

  belongs_to :user
  belongs_to :entity, polymorphic: true, optional: true
  validates :entity, presence: true, unless: :is_manual_adjustment?
  validates :for_date, presence: true

  # A blank word count means zero words written, never "unknown".
  # Normalize here so a blank manual-adjustment form submission (which
  # typecasts to nil for an integer column) is stored as 0.
  before_validation { self.word_count ||= 0 }

  after_commit :check_daily_word_goal, on: [:create, :update]

  # The previous row's word_count for the same entity, for rows whose day has no starting count.
  # One backwards probe per row on the unique (entity_type, entity_id, for_date) index.
  PREVIOUS_WORD_COUNT_SQL = <<~SQL.squish.freeze
    CASE WHEN word_count_updates.starting_word_count IS NULL
          AND word_count_updates.entity_type <> '#{MANUAL_ADJUSTMENT}'
    THEN (
      SELECT earlier.word_count
      FROM word_count_updates earlier
      WHERE earlier.entity_type = word_count_updates.entity_type
        AND earlier.entity_id = word_count_updates.entity_id
        AND earlier.for_date < word_count_updates.for_date
      ORDER BY earlier.for_date DESC
      LIMIT 1
    ) END
  SQL

  scope :with_previous_word_count, -> {
    select('word_count_updates.*', "#{PREVIOUS_WORD_COUNT_SQL} AS previous_word_count")
  }

  def is_manual_adjustment?
    entity_type == MANUAL_ADJUSTMENT
  end

  # The entity's word count when this row's day began.
  def starting_count
    return 0 if is_manual_adjustment?
    return starting_word_count unless starting_word_count.nil?

    previous_word_count.to_i
  end

  # The word_count of the entity's row before this one, if any. Loaded in bulk by
  # with_previous_word_count, otherwise looked up.
  def previous_word_count
    return self[:previous_word_count] if has_attribute?(:previous_word_count)
    return @previous_word_count if defined?(@previous_word_count)

    @previous_word_count = self.class
      .where(entity_type: entity_type, entity_id: entity_id)
      .where('for_date < ?', for_date)
      .order(for_date: :desc)
      .limit(1)
      .pick(:word_count)
  end

  # How much the entity grew on this row's day (negative if more was deleted than written).
  def words_added
    is_manual_adjustment? ? word_count.to_i : word_count.to_i - starting_count
  end

  # What this row adds to "words written" for its day.
  def counted_words
    is_manual_adjustment? ? word_count.to_i : [words_added, 0].max
  end

  # Gives a row written before starting counts were recorded (word_count by the old counter,
  # measured from the previous row) a starting count, without changing what it has already credited:
  # the day now runs from `count_now` (the entity's current count, by the current counter) less
  # those words.
  def convert_to_starting_count!(count_now)
    already_credited = [word_count.to_i - previous_word_count.to_i, 0].max
    update!(starting_word_count: [count_now - already_credited, 0].max)
  end

  # The date a change made at `time` counts towards, in the writer's own time zone.
  def self.date_for(user, time = Time.current)
    zone = user&.time_zone.presence
    zone ? time.in_time_zone(zone).to_date : time.to_date
  rescue ArgumentError # an unrecognized time zone name
    time.to_date
  end

  # Records an entity's word count for a day.
  #
  # The block is called only when this creates the day's row, and returns the count the day started
  # from (or nil if it isn't known, so the day is measured from the entity's previous row).
  def self.record!(entity, date:, word_count:, user_id: entity.user_id)
    attempts = 0
    begin
      row = entity.word_count_updates.find_or_initialize_by(for_date: date)
      row.starting_word_count = yield if row.new_record? && block_given?
      row.word_count = word_count
      row.user_id ||= user_id
      row.save!
      row
    rescue ActiveRecord::RecordNotUnique
      # Another job created the day's row first; update that one instead
      attempts += 1
      retry if attempts <= MAX_RETRY_ATTEMPTS
      raise
    end
  end

  private

  def check_daily_word_goal
    DailyWordGoalNotificationJob.perform_later(user_id) if user_id.present?
  rescue RedisClient::Error, Redis::BaseError => e
    # The notification is a nicety; never let Redis trouble fail the write that triggered it
    Rails.logger.warn "Could not queue DailyWordGoalNotificationJob for User #{user_id}: #{e.class}: #{e.message}"
  end

  public

  # Words written on a single date.
  def self.words_written_on_date(user, target_date)
    batch_words_written_on_dates(user, [target_date])[target_date] || 0
  end

  # Words written on each of the given dates: { date => words }.
  # Reads only the rows on those dates, each with one index probe for its previous row if needed.
  def self.batch_words_written_on_dates(user, dates)
    return {} if dates.empty?

    dates = dates.uniq.sort
    result = dates.index_with(0)

    rows = where(user: user, for_date: dates.first..dates.last).with_previous_word_count.to_a
    one_row_per_entity_and_date(rows).each do |row|
      result[row.for_date] += row.counted_words if result.key?(row.for_date)
    end

    result
  end

  # Alias for backwards compatibility - calls the efficient batch method
  def self.words_written_on_dates(user, dates)
    batch_words_written_on_dates(user, dates)
  end

  # Get all dates with writing activity in a range (single query)
  # Returns a Set of dates where the user wrote words (positive delta)
  def self.dates_with_writing_activity(user, start_date, end_date)
    word_counts = batch_words_written_on_dates(user, (start_date..end_date).to_a)
    word_counts.select { |_date, count| count > 0 }.keys.to_set
  end

  # Words written over a date range: each entity's net growth from the start of the range to its
  # end (an entity that shrank counts as 0), plus manual adjustments.
  def self.words_written_in_range(user, date_range)
    net_words_by_entity(user, date_range).sum do |(entity_type, _entity_id), words|
      entity_type == MANUAL_ADJUSTMENT ? words : [words, 0].max
    end
  end

  # Each entity's net growth over a date range: { [entity_type, entity_id] => words }, measured
  # from the count its first day in the range started from to its count at the end of the range.
  # Manual adjustments are summed as they are.
  def self.net_words_by_entity(user, date_range)
    rows = where(user: user, for_date: date_range).with_previous_word_count.to_a

    one_row_per_entity_and_date(rows).group_by { |row| [row.entity_type, row.entity_id] }.transform_values do |entity_rows|
      if entity_rows.first.is_manual_adjustment?
        entity_rows.sum { |row| row.word_count.to_i }
      else
        first, last = entity_rows.minmax_by(&:for_date)
        last.word_count.to_i - first.starting_count
      end
    end
  end

  # The unique index allows one row per entity per date, but rows from before it existed can be
  # duplicated by a race. Keep the highest count for each.
  def self.one_row_per_entity_and_date(rows)
    rows
      .group_by { |row| [row.entity_type, row.entity_id, row.for_date] }
      .map { |_key, dupes| dupes.max_by { |row| row.word_count.to_i } }
  end
  private_class_method :one_row_per_entity_and_date
end
