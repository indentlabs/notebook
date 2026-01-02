class WritingActivityController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sidenav_expansion

  def index
    @page_title = "Writing Activity"
    @date_range = calculate_date_range

    # Key metrics
    @words_written = WordCountUpdate.words_written_in_range(current_user, @date_range)
    @daily_word_counts = prepare_daily_chart_data
    @active_days = @daily_word_counts.count { |_date, count| count > 0 }
    @most_productive_day = find_most_productive_day
    @current_streak = calculate_streak

    # Chart data
    @words_by_type = prepare_type_breakdown

    # Activity log and top pages
    @recent_updates = fetch_recent_updates
    @top_growing_pages = fetch_top_growing_pages
  end

  private

  def set_sidenav_expansion
    @sidenav_expansion = 'writing'
  end

  def calculate_date_range
    user_today = current_user.current_date_in_time_zone
    (user_today - 6.days)..user_today
  end

  def prepare_daily_chart_data
    dates = @date_range.to_a
    WordCountUpdate.words_written_on_dates(current_user, dates)
  end

  def find_most_productive_day
    return nil if @daily_word_counts.empty?

    max_entry = @daily_word_counts.max_by { |_date, count| count }
    return nil if max_entry.nil? || max_entry[1] == 0

    { date: max_entry[0], words: max_entry[1] }
  end

  def calculate_streak
    user_today = current_user.current_date_in_time_zone
    streak = 0
    date = user_today

    # Look back up to 365 days to find the streak
    365.times do
      words = WordCountUpdate.words_written_on_date(current_user, date)
      if words > 0
        streak += 1
        date -= 1.day
      else
        # If today has no words yet, check if yesterday started a streak
        if date == user_today && streak == 0
          date -= 1.day
          next
        end
        break
      end
    end

    streak
  end

  def prepare_type_breakdown
    # Get word counts by entity type for the date range
    # We need to calculate deltas, not totals
    updates_in_range = current_user.word_count_updates
      .where(for_date: @date_range)
      .select(:entity_type, :entity_id, :word_count, :for_date)
      .order(:entity_type, :entity_id, :for_date)

    # Group by entity type
    type_totals = Hash.new(0)

    # For each entity, calculate the delta within the range
    updates_in_range.group_by { |u| [u.entity_type, u.entity_id] }.each do |(_type, _id), records|
      # Get the last record in range
      last_record = records.max_by(&:for_date)

      # Get the first record before the range for this entity
      first_before_range = current_user.word_count_updates
        .where(entity_type: last_record.entity_type, entity_id: last_record.entity_id)
        .where('for_date < ?', @date_range.first)
        .order(for_date: :desc)
        .first

      prev_count = first_before_range&.word_count || 0
      delta = last_record.word_count - prev_count
      type_totals[last_record.entity_type] += delta if delta > 0
    end

    type_totals
  end

  def fetch_recent_updates
    # Get recent word count updates with their entities and calculate deltas
    updates = current_user.word_count_updates
      .where(for_date: @date_range)
      .includes(:entity)
      .order(for_date: :desc, updated_at: :desc)

    # Calculate delta for each update by comparing to previous record
    updates_with_deltas = []
    updates.each do |update|
      # Find the previous record for this entity
      prev_record = current_user.word_count_updates
        .where(entity_type: update.entity_type, entity_id: update.entity_id)
        .where('for_date < ?', update.for_date)
        .order(for_date: :desc)
        .first

      prev_count = prev_record&.word_count || 0
      delta = update.word_count - prev_count

      # Only include if there was actual change
      next if delta == 0

      updates_with_deltas << {
        update: update,
        entity: update.entity,
        delta: delta,
        for_date: update.for_date
      }
    end

    updates_with_deltas.first(50)
  end

  def fetch_top_growing_pages
    # Calculate which pages grew the most in the date range
    updates_in_range = current_user.word_count_updates
      .where(for_date: @date_range)
      .select(:entity_type, :entity_id, :word_count, :for_date)

    # Calculate delta for each entity
    page_deltas = []

    updates_in_range.group_by { |u| [u.entity_type, u.entity_id] }.each do |(entity_type, entity_id), records|
      last_record = records.max_by(&:for_date)

      # Get the record before the range
      first_before_range = current_user.word_count_updates
        .where(entity_type: entity_type, entity_id: entity_id)
        .where('for_date < ?', @date_range.first)
        .order(for_date: :desc)
        .first

      prev_count = first_before_range&.word_count || 0
      delta = last_record.word_count - prev_count

      next unless delta > 0

      page_deltas << {
        entity_type: entity_type,
        entity_id: entity_id,
        words_added: delta
      }
    end

    # Sort by words added and take top 10
    top_pages = page_deltas.sort_by { |p| -p[:words_added] }.first(10)

    # Load the actual entities
    top_pages.each do |page|
      page[:entity] = page[:entity_type].constantize.find_by(id: page[:entity_id])
    end

    top_pages.reject { |p| p[:entity].nil? }
  end
end
