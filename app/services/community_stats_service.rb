# frozen_string_literal: true

# Anonymous, aggregate-only statistics about how much the whole Notebook.ai
# community is writing. Powers the public /community page.
#
# Nothing in here ever exposes an individual user's content or identity: every
# number is a total or a count across all writers.
#
# This class only reads the small pre-aggregated CommunityDailyStat and
# CommunityMonthlyWriter tables; CommunityStatsRollup does the heavy lifting in
# the background. Word counts follow the same rules as the per-user stats in
# WordCountUpdate: words written on a day are the positive growth of each
# page/document since its previous record, and deletions never subtract.
class CommunityStatsService
  CACHE_TTL     = 5.minutes
  CACHE_VERSION = 'v2'

  # Recent rollups older than this mean the hourly refresh (cron) isn't running,
  # so the page enqueues one itself. Keep this longer than the cron interval.
  STALE_AFTER = 90.minutes

  # Days of daily history loaded for charts, the heatmap, and weekday averages.
  HISTORY_DAYS = 400

  # A typical novel-length manuscript, used for "that's N novels" framing.
  NOVEL_LENGTH = 50_000

  # How WordCountUpdate entity types are grouped for display. Anything not
  # listed here (all other worldbuilding page types) falls under OTHER_CATEGORY.
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

  def self.category_for(entity_type)
    WRITING_CATEGORIES.fetch(entity_type, OTHER_CATEGORY)
  end

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

  def initialize(today: Date.current)
    @today = today
  end

  attr_reader :today

  # True when the recent rollups haven't been refreshed lately (or ever).
  def stale?
    last = cached('last_refreshed_at') do
      CommunityDailyStat.where(metric: 'writers', date: today).maximum(:updated_at)
    end
    last.nil? || last < STALE_AFTER.ago
  end

  # ---------------------------------------------------------------------------
  # Headline numbers
  # ---------------------------------------------------------------------------

  def words_today
    daily_words[today] || 0
  end

  def writers_today
    daily_writers[today] || 0
  end

  def words_yesterday
    daily_words[today - 1.day] || 0
  end

  # Distinct writers whose word counts changed in the hour before the last refresh.
  def writers_this_hour
    latest_value('writers_last_hour')
  end

  def all_time_writers
    latest_value('all_time_writers')
  end

  def all_time_words
    cached('all_time_words') { CommunityDailyStat.where(metric: 'words').sum(:value) }
  end

  def first_tracked_date
    cached('first_tracked_date') { CommunityDailyStat.where(metric: 'words').where('value > 0').minimum(:date) }
  end

  def novels_equivalent(words)
    (words.to_f / NOVEL_LENGTH).floor
  end

  # ---------------------------------------------------------------------------
  # Daily & monthly series
  # ---------------------------------------------------------------------------

  # { date => words } for the last HISTORY_DAYS days.
  def daily_words
    @daily_words ||= words_by_date_and_category.transform_values { |by_category| by_category.values.sum }
  end

  # [[date, words], ...] for the last `days` days, oldest first, zero-filled.
  def daily_series(days: 30)
    ((today - (days - 1).days)..today).map { |date| [date, daily_words[date] || 0] }
  end

  # { date => distinct writers } for the last HISTORY_DAYS days.
  def daily_writers
    @daily_writers ||= cached('daily_writers') do
      CommunityDailyStat.where(metric: 'writers', date: history_range).group(:date).sum(:value)
    end
  end

  # [[Date (first of month), words], ...] for the last `months` months, oldest first.
  def monthly_series(months: 12)
    month_starts(months).map { |month| [month, words_in_month(month)] }
  end

  def words_in_month(month_start)
    month_range = month_start.beginning_of_month..month_start.end_of_month
    daily_words.sum { |date, words| month_range.cover?(date) ? words : 0 }
  end

  def writers_in_month(month_start)
    monthly_writers[month_start.beginning_of_month] || 0
  end

  # { Date (first of month) => distinct writers } for the last 13 months.
  def monthly_writers
    @monthly_writers ||= cached('monthly_writers') do
      CommunityMonthlyWriter
        .where('month >= ?', (today - 12.months).beginning_of_month)
        .group(:month)
        .count
    end
  end

  # ---------------------------------------------------------------------------
  # What the community is writing
  # ---------------------------------------------------------------------------

  # { category => words } for a given month, most first.
  def words_by_category_in_month(month_start)
    month_range = month_start.beginning_of_month..month_start.end_of_month
    totals = Hash.new(0)

    words_by_date_and_category.each do |date, by_category|
      next unless month_range.cover?(date)
      by_category.each { |category, words| totals[category] += words }
    end

    totals.sort_by { |_, words| -words }.to_h
  end

  # For a stacked chart: [{ name: category, data: [['Mon YYYY', words], ...] }, ...]
  def monthly_category_series(months: 12)
    @monthly_category_series ||= {}
    @monthly_category_series[months] ||= begin
      starts = month_starts(months)
      per_month = starts.index_with { |month| words_by_category_in_month(month) }
      categories = per_month.values.flat_map(&:keys).uniq
      categories = categories.sort_by { |category| -per_month.values.sum { |totals| totals[category] || 0 } }

      categories.map do |category|
        {
          name: category,
          data: starts.map { |month| [month.strftime('%b %Y'), per_month[month][category] || 0] }
        }
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Rhythms & records
  # ---------------------------------------------------------------------------

  # Most words written by the community in a single complete day, ever.
  def record_day
    date, words = cached('record_day') do
      CommunityDailyStat
        .where(metric: 'words')
        .where('date < ?', today)
        .group(:date)
        .order(Arel.sql('SUM(value) DESC'))
        .limit(1)
        .sum(:value)
        .first
    end
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

  # These come from the nightly EndOfDayAnalyticsReport rows, so the current
  # month counts through yesterday.

  # { 'Character' => count, ... } for pages created in the given month, most first.
  def pages_created_in_month(month_start)
    cached("pages_created/#{month_start.strftime('%Y-%m')}") do
      columns = self.class.page_classes.index_by { |klass| "#{klass.name.downcase.pluralize}_created" }
      totals = eod_reports_in_month(month_start).pluck(*columns.keys.map { |c| Arel.sql("SUM(#{c})") }).first || []

      columns.values.map(&:name).zip(totals)
        .select { |_, count| count.to_i > 0 }
        .map { |name, count| [name, count.to_i] }
        .sort_by { |_, count| -count }
        .to_h
    end
  end

  # { 'Character' => count, ... } distinct pages edited in the given month,
  # most first. Rolled up nightly, so the current month counts through yesterday.
  def pages_edited_in_month(month_start)
    cached("pages_edited/#{month_start.strftime('%Y-%m')}") do
      CommunityDailyStat
        .where(metric: 'pages_edited', date: month_start.beginning_of_month)
        .pluck(:key, :value)
        .sort_by { |_, count| -count }
        .to_h
    end
  end

  def new_writers_in_month(month_start)
    eod_sum('user_signups', month_start)
  end

  def goals_completed_in_month(month_start)
    eod_sum('writing_goals_completed', month_start)
  end

  def forum_posts_in_month(month_start)
    eod_sum('thredded_replies_created', month_start)
  end

  # Every page type that can appear in the edited/created breakdown.
  def self.display_page_classes
    page_classes + [Book]
  end

  # Page types whose creation counts are shown (all have *_created EOD columns).
  def self.page_classes
    Rails.application.config.content_types[:all] + [Document, Timeline]
  end

  private

  def history_range
    (today - HISTORY_DAYS.days)..today
  end

  def month_starts(months)
    (0...months).map { |i| (today - i.months).beginning_of_month }.reverse
  end

  def cached(key, &block)
    Rails.cache.fetch("community_stats/#{CACHE_VERSION}/#{today}/#{key}", expires_in: CACHE_TTL, &block)
  end

  # { date => { category => words } } for the last HISTORY_DAYS days.
  def words_by_date_and_category
    @words_by_date_and_category ||= cached('words_by_date_and_category') do
      CommunityDailyStat
        .where(metric: 'words', date: history_range)
        .group(:date, :key)
        .sum(:value)
        .each_with_object({}) do |((date, category), words), by_date|
          (by_date[date] ||= {})[category] = words
        end
    end
  end

  def latest_value(metric)
    cached("latest/#{metric}") do
      CommunityDailyStat.where(metric: metric).order(date: :desc).limit(1).pluck(:value).first || 0
    end
  end

  def eod_reports_in_month(month_start)
    EndOfDayAnalyticsReport.where(day: month_start.beginning_of_month..month_start.end_of_month)
  end

  def eod_sum(column, month_start)
    cached("eod/#{column}/#{month_start.strftime('%Y-%m')}") { eod_reports_in_month(month_start).sum(column).to_i }
  end
end
