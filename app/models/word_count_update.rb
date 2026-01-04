class WordCountUpdate < ApplicationRecord
  belongs_to :user
  belongs_to :entity, polymorphic: true

  after_commit :check_daily_word_goal, on: [:create, :update]

  private

  def check_daily_word_goal
    DailyWordGoalNotificationJob.perform_later(user_id) if user_id.present?
  end

  public

  # Calculate actual words written on a specific date (delta from previous day)
  # Uses ActiveRecord for database-agnostic queries
  def self.words_written_on_date(user, target_date)
    # Get all records for the target date
    today_records = where(user: user, for_date: target_date)
      .select(:entity_type, :entity_id, :word_count)
      .to_a

    return 0 if today_records.empty?

    # Get the previous record for each entity in a single query using a subquery
    entity_keys = today_records.map { |r| [r.entity_type, r.entity_id] }

    # Find the max for_date before target_date for each entity
    prev_records = where(user: user)
      .where('for_date < ?', target_date)
      .where(entity_type: entity_keys.map(&:first).uniq)
      .group(:entity_type, :entity_id)
      .select(:entity_type, :entity_id, 'MAX(for_date) as max_date')
      .to_a

    # Fetch the actual word counts for those dates
    prev_word_counts = {}
    prev_records.each do |pr|
      record = find_by(
        user: user,
        entity_type: pr.entity_type,
        entity_id: pr.entity_id,
        for_date: pr.max_date
      )
      prev_word_counts[[pr.entity_type, pr.entity_id]] = record&.word_count || 0
    end

    # Calculate deltas
    total_delta = 0
    today_records.each do |record|
      prev_count = prev_word_counts[[record.entity_type, record.entity_id]] || 0
      delta = record.word_count - prev_count
      total_delta += delta if delta > 0
    end

    total_delta
  end

  # Batch calculate words written for multiple dates
  # Returns a hash of { date => word_count }
  def self.words_written_on_dates(user, dates)
    return {} if dates.empty?

    # For simplicity, call words_written_on_date for each date
    # This is still efficient since each call is only 2-3 queries
    dates.each_with_object({}) do |date, hash|
      hash[date] = words_written_on_date(user, date)
    end
  end

  # Calculate actual words written in a date range
  # Compares the final word count in the range vs the day before the range started
  def self.words_written_in_range(user, date_range)
    start_date = date_range.first
    end_date = date_range.last

    # Get the latest record for each entity within the date range
    latest_in_range = where(user: user, for_date: date_range)
      .group(:entity_type, :entity_id)
      .select(:entity_type, :entity_id, 'MAX(for_date) as max_date')
      .to_a

    return 0 if latest_in_range.empty?

    # Fetch the actual word counts for the latest dates
    current_word_counts = {}
    latest_in_range.each do |lr|
      record = find_by(
        user: user,
        entity_type: lr.entity_type,
        entity_id: lr.entity_id,
        for_date: lr.max_date
      )
      current_word_counts[[lr.entity_type, lr.entity_id]] = record&.word_count || 0
    end

    # Get the previous record for each entity before the range started
    entity_keys = latest_in_range.map { |r| [r.entity_type, r.entity_id] }

    prev_records = where(user: user)
      .where('for_date < ?', start_date)
      .where(entity_type: entity_keys.map(&:first).uniq)
      .group(:entity_type, :entity_id)
      .select(:entity_type, :entity_id, 'MAX(for_date) as max_date')
      .to_a

    prev_word_counts = {}
    prev_records.each do |pr|
      record = find_by(
        user: user,
        entity_type: pr.entity_type,
        entity_id: pr.entity_id,
        for_date: pr.max_date
      )
      prev_word_counts[[pr.entity_type, pr.entity_id]] = record&.word_count || 0
    end

    # Calculate deltas
    total_delta = 0
    entity_keys.each do |key|
      current = current_word_counts[key] || 0
      prev = prev_word_counts[key] || 0
      delta = current - prev
      total_delta += delta if delta > 0
    end

    total_delta
  end
end
