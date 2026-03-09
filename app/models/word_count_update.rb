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

    # Defensive: Dedupe by entity (in case of duplicate records from race conditions)
    # Keep the record with the highest word_count per entity
    today_records = today_records
      .group_by { |r| [r.entity_type, r.entity_id] }
      .transform_values { |records| records.max_by(&:word_count) }
      .values

    # Get the previous record for each entity in a single query using a subquery
    entity_ids_by_type = today_records.group_by(&:entity_type).transform_values { |recs| recs.map(&:entity_id).uniq }

    prev_records = []
    entity_ids_by_type.each do |type, ids|
      prev_records.concat(
        where(user: user)
          .where('for_date < ?', target_date)
          .where(entity_type: type, entity_id: ids)
          .group(:entity_type, :entity_id)
          .select(:entity_type, :entity_id, 'MAX(for_date) as max_date')
          .to_a
      )
    end

    # Fetch the actual word counts for those dates in bulk (avoids N+1)
    prev_word_counts = {}

    if prev_records.any?
      # Build conditions for bulk fetch using OR clauses
      conditions = prev_records.map do |pr|
        sanitize_sql_array([
          "(entity_type = ? AND entity_id = ? AND for_date = ?)",
          pr.entity_type, pr.entity_id, pr.max_date
        ])
      end

      records = where(user: user)
        .where(conditions.join(' OR '))
        .select(:entity_type, :entity_id, :word_count)

      records.each do |r|
        prev_word_counts[[r.entity_type, r.entity_id]] = r.word_count
      end
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

  # Batch calculate words written for multiple dates efficiently
  # Returns a hash of { date => word_count }
  # Uses a single query to fetch all data, then calculates deltas in Ruby
  def self.batch_words_written_on_dates(user, dates)
    return {} if dates.empty?

    dates = dates.sort
    earliest_date = dates.first
    latest_date = dates.last

    # Fetch all records in the date range plus records before earliest_date for baseline
    # We need records from before earliest_date to calculate delta for the first date
    all_records = where(user: user)
      .where('for_date <= ?', latest_date)
      .select(:entity_type, :entity_id, :word_count, :for_date)
      .order(:entity_type, :entity_id, :for_date)
      .to_a

    return dates.each_with_object({}) { |d, h| h[d] = 0 } if all_records.empty?

    # Group records by entity
    records_by_entity = all_records.group_by { |r| [r.entity_type, r.entity_id] }

    # For each target date, calculate delta for each entity
    result = {}
    dates.each do |target_date|
      total_delta = 0

      records_by_entity.each do |_entity_key, entity_records|
        # Find the record for target_date (if any)
        today_record = entity_records.find { |r| r.for_date == target_date }
        next unless today_record

        # Find the previous record (most recent before target_date)
        prev_record = entity_records
          .select { |r| r.for_date < target_date }
          .max_by(&:for_date)

        prev_count = prev_record&.word_count || 0
        delta = today_record.word_count - prev_count
        total_delta += delta if delta > 0
      end

      result[target_date] = total_delta
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

    # Fetch the actual word counts for the latest dates in bulk (avoids N+1)
    current_word_counts = {}

    if latest_in_range.any?
      conditions = latest_in_range.map do |lr|
        sanitize_sql_array([
          "(entity_type = ? AND entity_id = ? AND for_date = ?)",
          lr.entity_type, lr.entity_id, lr.max_date
        ])
      end

      records = where(user: user)
        .where(conditions.join(' OR '))
        .select(:entity_type, :entity_id, :word_count)

      records.each do |r|
        current_word_counts[[r.entity_type, r.entity_id]] = r.word_count
      end
    end

    # Get the previous record for each entity before the range started
    entity_ids_by_type = latest_in_range.group_by(&:entity_type).transform_values { |recs| recs.map(&:entity_id).uniq }

    prev_records = []
    entity_ids_by_type.each do |type, ids|
      prev_records.concat(
        where(user: user)
          .where('for_date < ?', start_date)
          .where(entity_type: type, entity_id: ids)
          .group(:entity_type, :entity_id)
          .select(:entity_type, :entity_id, 'MAX(for_date) as max_date')
          .to_a
      )
    end

    # Fetch the actual word counts for those dates in bulk (avoids N+1)
    prev_word_counts = {}

    if prev_records.any?
      conditions = prev_records.map do |pr|
        sanitize_sql_array([
          "(entity_type = ? AND entity_id = ? AND for_date = ?)",
          pr.entity_type, pr.entity_id, pr.max_date
        ])
      end

      records = where(user: user)
        .where(conditions.join(' OR '))
        .select(:entity_type, :entity_id, :word_count)

      records.each do |r|
        prev_word_counts[[r.entity_type, r.entity_id]] = r.word_count
      end
    end

    # Calculate deltas
    total_delta = 0
    current_word_counts.keys.each do |key|
      current = current_word_counts[key] || 0
      prev = prev_word_counts[key] || 0
      delta = current - prev
      total_delta += delta if delta > 0
    end

    total_delta
  end
end
