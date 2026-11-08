class WritingActivityController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sidenav_expansion

  def index
    @page_title = "Writing Activity"
    @period = params[:period].presence || '7d'
    @period = '7d' unless %w[24h 7d 30d].include?(@period)
    @date_range = calculate_date_range
    @period_label = period_label
    @period_days = @date_range.count

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
    case @period
    when '24h'
      user_today..user_today
    when '30d'
      (user_today - 29.days)..user_today
    else # '7d'
      (user_today - 6.days)..user_today
    end
  end

  def period_label
    case @period
    when '24h' then 'today'
    when '30d' then 'the last 30 days'
    else 'the last 7 days'
    end
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
    # One query for the past year rather than one per day
    active_dates = WordCountUpdate.dates_with_writing_activity(current_user, user_today - 365.days, user_today)

    # If today has no words yet, a streak that ran through yesterday still counts
    date = active_dates.include?(user_today) ? user_today : user_today - 1.day
    streak = 0
    while active_dates.include?(date)
      streak += 1
      date -= 1.day
    end

    streak
  end

  # { [entity_type, entity_id] => net words over the period }, including manual adjustments
  def net_words_by_entity
    @net_words_by_entity ||= WordCountUpdate.net_words_by_entity(current_user, @date_range)
  end

  # Each tracked page's net growth over the period (pages that shrank count as 0)
  def entity_growth
    net_words_by_entity.reject do |(entity_type, _entity_id), words|
      entity_type == WordCountUpdate::MANUAL_ADJUSTMENT || words <= 0
    end
  end

  def prepare_type_breakdown
    type_totals = Hash.new(0)
    entity_growth.each { |(entity_type, _entity_id), words| type_totals[entity_type] += words }

    manual_words = net_words_by_entity
      .select { |(entity_type, _entity_id), _words| entity_type == WordCountUpdate::MANUAL_ADJUSTMENT }
      .values.sum
    type_totals['Logged by hand'] = manual_words if manual_words > 0

    type_totals
  end

  def fetch_recent_updates
    # Each day's change to each page, measured the same way as the daily totals
    updates = current_user.word_count_updates
      .where(for_date: @date_range)
      .where.not(entity_type: WordCountUpdate::MANUAL_ADJUSTMENT)
      .with_previous_word_count
      .includes(:entity)
      .order(for_date: :desc, updated_at: :desc)

    updates_with_deltas = []
    updates.each do |update|
      delta = update.words_added

      # Only include if there was actual change
      next if delta == 0

      updates_with_deltas << {
        update: update,
        entity: update.entity,
        delta: delta,
        for_date: update.for_date
      }
      break if updates_with_deltas.size >= 50
    end

    updates_with_deltas
  end

  def fetch_top_growing_pages
    top_pages = entity_growth
      .sort_by { |_key, words| -words }
      .first(10)
      .map { |(entity_type, entity_id), words| { entity_type: entity_type, entity_id: entity_id, words_added: words } }

    # Load the actual entities
    top_pages.each do |page|
      page[:entity] = page[:entity_type].safe_constantize&.find_by(id: page[:entity_id])
    end

    top_pages.reject { |p| p[:entity].nil? }
  end
end
