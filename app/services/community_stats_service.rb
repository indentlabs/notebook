# frozen_string_literal: true

# Anonymous, aggregate-only statistics about how much the whole Notebook.ai
# community is writing. Powers the public /community page.
#
# Nothing in here ever exposes an individual user's content or identity: every
# number is a total or a count across all writers.
#
# Word counts follow the same rules as the per-user stats in WordCountUpdate:
# words written on a day are the positive growth of each page/document since
# its previous WordCountUpdate record. Deletions never subtract.
#
# The deltas are computed in SQL with a LAG() window function so a year of
# community-wide history is a handful of queries instead of one query per
# entity. Results are cached; the historical data (everything before today)
# changes rarely and is cached for hours, while "today" is cached for minutes.
class CommunityStatsService
  HISTORY_CACHE_TTL = 6.hours
  LIVE_CACHE_TTL    = 10.minutes
  CACHE_VERSION     = 'v1'

  # A typical novel-length manuscript, used for "that's N novels" framing.
  NOVEL_LENGTH = 50_000

  # How WordCountUpdate entity types are grouped for display. Anything not
  # listed here (all other worldbuilding page types) falls under 'Other pages'.
  WRITING_CATEGORIES = {
    'Document'         => 'Documents',
    'Character'        => 'Characters',
    'Location'         => 'Locations',
    'Item'             => 'Items',
    'Universe'         => 'Universes',
    'TimelineEvent'    => 'Timelines',
    'Book'             => 'Books',
    'ManualAdjustment' => 'Logged by hand'
  }.freeze
  OTHER_CATEGORY = 'Other worldbuilding'

  def initialize(today: Date.current)
    @today = today
  end

  attr_reader :today

  # ---------------------------------------------------------------------------
  # Headline numbers
  # ---------------------------------------------------------------------------

  def words_today
    live_stats[:words]
  end

  def writers_today
    live_stats[:writers]
  end

  # Distinct writers whose word counts changed in the last hour.
  def writers_this_hour
    live_stats[:writers_this_hour]
  end

  def words_yesterday
    daily_words[today - 1.day] || 0
  end

  def all_time_words
    history[:words_by_date_and_category].values.sum { |by_category| by_category.values.sum } + words_today
  end

  def all_time_writers
    cached('all_time_writers', HISTORY_CACHE_TTL) do
      WordCountUpdate.distinct.count(:user_id)
    end
  end

  def first_tracked_date
    history[:words_by_date_and_category].keys.min
  end

  def novels_equivalent(words)
    (words.to_f / NOVEL_LENGTH).floor
  end

  # ---------------------------------------------------------------------------
  # Daily & monthly series
  # ---------------------------------------------------------------------------

  # { date => words } for every date with activity, including today.
  def daily_words
    @daily_words ||= begin
      totals = history[:words_by_date_and_category].transform_values { |by_category| by_category.values.sum }
      totals[today] = words_today
      totals
    end
  end

  # [[label, words], ...] for the last `days` days, oldest first, zero-filled.
  def daily_series(days: 30)
    ((today - (days - 1).days)..today).map { |date| [date, daily_words[date] || 0] }
  end

  # { date => distinct writers } for the last year, including today.
  def daily_writers
    @daily_writers ||= history[:writers_by_date].merge(today => writers_today)
  end

  # [[Date (first of month), words], ...] for the last `months` months, oldest first.
  def monthly_series(months: 12)
    month_starts(months).map { |month| [month, words_in_month(month)] }
  end

  def words_in_month(month_start)
    month_range = month_start.beginning_of_month..month_start.end_of_month
    daily_words.sum { |date, words| month_range.cover?(date) ? words : 0 }
  end

  # { 'YYYY-MM' => distinct writers }
  def monthly_writers
    history[:writers_by_month]
  end

  def writers_in_month(month_start)
    monthly_writers[month_start.strftime('%Y-%m')] || 0
  end

  # ---------------------------------------------------------------------------
  # What the community is writing
  # ---------------------------------------------------------------------------

  # { category => words } for a given month (today included when relevant).
  def words_by_category_in_month(month_start)
    month_range = month_start.beginning_of_month..month_start.end_of_month
    totals = Hash.new(0)

    history[:words_by_date_and_category].each do |date, by_category|
      next unless month_range.cover?(date)
      by_category.each { |category, words| totals[category] += words }
    end

    if month_range.cover?(today)
      live_stats[:words_by_category].each { |category, words| totals[category] += words }
    end

    totals.sort_by { |_, words| -words }.to_h
  end

  # For a stacked chart: [{ name: category, data: { 'Mon YYYY' => words } }, ...]
  def monthly_category_series(months: 12)
    starts = month_starts(months)
    per_month = starts.map { |month| [month, words_by_category_in_month(month)] }.to_h
    categories = per_month.values.flat_map(&:keys).uniq
    categories = categories.sort_by { |category| -per_month.values.sum { |totals| totals[category] || 0 } }

    categories.map do |category|
      {
        name: category,
        data: starts.map { |month| [month.strftime('%b %Y'), per_month[month][category] || 0] }
      }
    end
  end

  # ---------------------------------------------------------------------------
  # Rhythms & records
  # ---------------------------------------------------------------------------

  # Most words written by the community in a single (complete) day.
  def record_day
    date, words = daily_words.reject { |d, _| d == today }.max_by { |_, w| w }
    return nil if date.nil? || words.to_i <= 0
    { date: date, words: words }
  end

  def busiest_month(months: 12)
    month, words = monthly_series(months: months).max_by { |_, w| w }
    return nil if month.nil? || words.to_i <= 0
    { month: month, words: words }
  end

  # Average words per weekday over the last year of complete days.
  # Returns [[day_name, average_words], ...] Monday first.
  def weekday_averages
    @weekday_averages ||= begin
      range = (today - 364.days)..(today - 1.day)
      sums = Hash.new(0)
      counts = Hash.new(0)
      range.each do |date|
        sums[date.cwday] += daily_words[date] || 0
        counts[date.cwday] += 1
      end
      (1..7).map { |cwday| [Date::DAYNAMES[cwday % 7], counts[cwday].zero? ? 0 : (sums[cwday] / counts[cwday])] }
    end
  end

  def favorite_weekday
    day, words = weekday_averages.max_by { |_, w| w }
    return nil if words.to_i <= 0
    { day: day, average_words: words }
  end

  # Weeks of [date, words] (Sunday-first) covering the last year, for a
  # contribution-style heatmap. Dates in the future are nil.
  def heatmap_weeks(weeks: 53)
    start = (today - (weeks * 7 - 1).days).beginning_of_week(:sunday)
    (start..today.end_of_week(:sunday)).each_slice(7).map do |week|
      week.map { |date| date > today ? nil : [date, daily_words[date] || 0] }
    end
  end

  # Thresholds splitting non-zero days into 4 intensity buckets (quartiles
  # of the last year), so the heatmap stays readable as the community grows.
  def heatmap_thresholds
    @heatmap_thresholds ||= begin
      values = daily_words.select { |date, words| date > today - 1.year && words > 0 }.values.sort
      if values.empty?
        [1, 1, 1]
      else
        [0.25, 0.5, 0.75].map { |q| values[(q * (values.length - 1)).floor] }
      end
    end
  end

  def heatmap_level(words)
    return 0 if words.to_i <= 0
    low, mid, high = heatmap_thresholds
    return 1 if words <= low
    return 2 if words <= mid
    return 3 if words <= high
    4
  end

  # ---------------------------------------------------------------------------
  # Beyond word counts: what the community built this month
  # ---------------------------------------------------------------------------

  # { 'Character' => count, ... } for pages created in the given month, most first.
  def pages_created_in_month(month_start)
    cached("pages_created/#{month_start.strftime('%Y-%m')}", month_start.beginning_of_month == today.beginning_of_month ? LIVE_CACHE_TTL * 3 : HISTORY_CACHE_TTL) do
      range = month_start.beginning_of_month.beginning_of_day..month_start.end_of_month.end_of_day
      klasses = Rails.application.config.content_types[:all] + [Document, Timeline]
      klasses.each_with_object({}) do |klass, counts|
        count = klass.where(created_at: range).count
        counts[klass.name] = count if count > 0
      end.sort_by { |_, count| -count }.to_h
    end
  end

  def new_writers_in_month(month_start)
    cached("new_writers/#{month_start.strftime('%Y-%m')}", LIVE_CACHE_TTL * 3) do
      User.where(created_at: month_start.beginning_of_month.beginning_of_day..month_start.end_of_month.end_of_day).count
    end
  end

  def goals_completed_in_month(month_start)
    cached("goals_completed/#{month_start.strftime('%Y-%m')}", LIVE_CACHE_TTL * 3) do
      WritingGoal.where(completed_at: month_start.beginning_of_month.beginning_of_day..month_start.end_of_month.end_of_day).count
    end
  end

  def forum_posts_in_month(month_start)
    cached("forum_posts/#{month_start.strftime('%Y-%m')}", LIVE_CACHE_TTL * 3) do
      Thredded::Post
        .where(moderation_state: 'approved')
        .where(created_at: month_start.beginning_of_month.beginning_of_day..month_start.end_of_month.end_of_day)
        .count
    end
  end

  def self.category_for(entity_type)
    WRITING_CATEGORIES.fetch(entity_type, OTHER_CATEGORY)
  end

  # Model class whose icon/colors represent a category, where there is one.
  CATEGORY_CLASS_NAMES = {
    'Documents'  => 'Document',
    'Characters' => 'Character',
    'Locations'  => 'Location',
    'Items'      => 'Item',
    'Universes'  => 'Universe',
    'Timelines'  => 'Timeline',
    'Books'      => 'Book'
  }.freeze

  # { icon:, hex_color: } for displaying a writing category.
  def self.category_style(category)
    klass = CATEGORY_CLASS_NAMES[category]&.safe_constantize
    return { icon: klass.icon, hex_color: klass.hex_color } if klass

    if category == WRITING_CATEGORIES['ManualAdjustment']
      { icon: 'edit_note', hex_color: '#607D8B' }
    else
      { icon: 'public', hex_color: '#9E9E9E' }
    end
  end

  # Pre-compute the expensive pieces so page loads hit a warm cache.
  def warm!
    history
    live_stats
    all_time_writers
    pages_created_in_month(today)
    pages_created_in_month(today.prev_month)
    self
  end

  private

  def month_starts(months)
    (0...months).map { |i| (today - i.months).beginning_of_month }.reverse
  end

  def cached(key, ttl, &block)
    Rails.cache.fetch("community_stats/#{CACHE_VERSION}/#{today}/#{key}", expires_in: ttl, race_condition_ttl: 1.minute, &block)
  end

  # Everything before today. Keyed on today's date so the cache rolls over at
  # midnight and yesterday's final numbers get picked up.
  def history
    @history ||= cached('history', HISTORY_CACHE_TTL) do
      words = Hash.new { |h, k| h[k] = Hash.new(0) }
      rows = connection.select_all(<<~SQL)
        SELECT for_date, entity_type, SUM(delta) AS words
        FROM (#{deltas_sql(to: today - 1.day)}) deltas
        GROUP BY for_date, entity_type
      SQL
      rows.each do |row|
        words[row['for_date'].to_date][self.class.category_for(row['entity_type'])] += row['words'].to_i
      end

      year_start = today - 1.year
      writers_by_date = connection.select_all(<<~SQL).to_a.to_h { |row| [row['for_date'].to_date, row['writers'].to_i] }
        SELECT for_date, COUNT(DISTINCT user_id) AS writers
        FROM (#{deltas_sql(from: year_start, to: today - 1.day)}) deltas
        GROUP BY for_date
      SQL

      writers_by_month = connection.select_all(<<~SQL).to_a.to_h { |row| [row['month'], row['writers'].to_i] }
        SELECT #{month_expression('for_date')} AS month, COUNT(DISTINCT user_id) AS writers
        FROM (#{deltas_sql(from: (today - 12.months).beginning_of_month, to: today + 1.day)}) deltas
        GROUP BY #{month_expression('for_date')}
      SQL

      {
        words_by_date_and_category: words.transform_values { |by_category| Hash[by_category] }.to_h,
        writers_by_date:            writers_by_date,
        writers_by_month:           writers_by_month
      }
    end
  end

  # Today's numbers. Users in time zones ahead of the server may already be
  # writing on tomorrow's date, so "today" includes any future-dated records.
  def live_stats
    @live_stats ||= cached('live', LIVE_CACHE_TTL) do
      by_category = Hash.new(0)
      writers = Set.new

      rows = connection.select_all(<<~SQL)
        SELECT user_id, entity_type, SUM(delta) AS words
        FROM (#{deltas_sql(from: today, to: today + 1.day)}) deltas
        GROUP BY user_id, entity_type
      SQL
      rows.each do |row|
        by_category[self.class.category_for(row['entity_type'])] += row['words'].to_i
        writers << row['user_id']
      end

      writers_this_hour = WordCountUpdate
        .where(for_date: (today - 1.day)..(today + 1.day))
        .where('updated_at > ?', 1.hour.ago)
        .distinct
        .count(:user_id)

      {
        words:             by_category.values.sum,
        words_by_category: Hash[by_category],
        writers:           writers.size,
        writers_this_hour: writers_this_hour
      }
    end
  end

  # SQL for a subquery yielding one row per (entity, date) with a positive
  # word count delta: (user_id, entity_type, for_date, delta).
  #
  # The previous record for each entity may fall before `from`, so the window
  # runs over each entity's full history; when `from` is given, only entities
  # with activity in the range are included, which keeps it cheap.
  def deltas_sql(to:, from: nil)
    in_range = from ? 'AND for_date >= :from' : ''
    active_entities = if from
      'AND (entity_type, entity_id) IN (SELECT entity_type, entity_id FROM word_count_updates WHERE for_date >= :from AND for_date <= :to)'
    else
      ''
    end

    WordCountUpdate.sanitize_sql_array([<<~SQL, { from: from, to: to }])
      SELECT user_id, entity_type, for_date, delta FROM (
        SELECT user_id, entity_type, for_date,
               COALESCE(word_count, 0) - COALESCE(LAG(word_count) OVER (PARTITION BY entity_type, entity_id ORDER BY for_date), 0) AS delta
        FROM word_count_updates
        WHERE for_date <= :to #{active_entities}
      ) entity_deltas
      WHERE delta > 0 #{in_range}
    SQL
  end

  def month_expression(column)
    if connection.adapter_name.downcase.include?('sqlite')
      "strftime('%Y-%m', #{column})"
    else
      "to_char(#{column}, 'YYYY-MM')"
    end
  end

  def connection
    WordCountUpdate.connection
  end
end
