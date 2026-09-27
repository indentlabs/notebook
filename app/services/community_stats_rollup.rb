# frozen_string_literal: true

# Computes the anonymous community stats for one day and stores them in
# CommunityDailyStat / CommunityMonthlyWriter, which CommunityStatsService
# reads to render the public /community page.
#
# Everything here is designed to stay cheap on very large tables:
#
# * Words: only the word_count_updates rows for the day are read (via the
#   for_date index). Each row's previous record is a single backwards probe
#   on the (entity_type, entity_id, for_date) unique index.
# * Pages created / sign-ups / forum posts: those tables have no created_at
#   index, so instead of scanning them we binary search the primary key for
#   the first id created at or after a given time (ids and created_at grow
#   together), then count an id range.
#
# Recent days are refreshed regularly (see CommunityStatsRefreshJob); history
# is filled once with `rake community:backfill`.
class CommunityStatsRollup
  # Page types whose creation counts are shown on the page.
  def self.page_classes
    Rails.application.config.content_types[:all] + [Document, Timeline]
  end

  # Re-rolls the last few days (writers in time zones behind the server are
  # still adding to "yesterday"), plus the point-in-time metrics.
  def self.refresh_recent!(today: Date.current)
    boundaries = IdBoundaries.new
    ((today - 2.days)..today).each { |date| new(date, boundaries: boundaries).run! }

    record_point_in_time_metrics!(today)
  end

  def self.record_point_in_time_metrics!(today)
    writers_last_hour = WordCountUpdate
      .where(for_date: (today - 1.day)..(today + 1.day))
      .where('updated_at > ?', 1.hour.ago)
      .distinct
      .count(:user_id)

    replace!(today, 'writers_last_hour', { '' => writers_last_hour })
    replace!(today, 'all_time_writers', { '' => CommunityMonthlyWriter.distinct.count(:user_id) })
  end

  # Swap all rows of one metric for one date in a single transaction.
  def self.replace!(date, metric, values_by_key)
    now = Time.current
    rows = values_by_key.map do |key, value|
      { date: date, metric: metric, key: key.to_s, value: value.to_i, created_at: now, updated_at: now }
    end

    CommunityDailyStat.transaction do
      CommunityDailyStat.where(date: date, metric: metric).delete_all
      CommunityDailyStat.insert_all!(rows) if rows.any?
    end
  end

  attr_reader :date

  def initialize(date, boundaries: IdBoundaries.new)
    @date = date
    @boundaries = boundaries
  end

  def run!
    roll_up_words!
    roll_up_creations!
    self
  end

  private

  def roll_up_words!
    words_by_category = Hash.new(0)
    writer_ids = Set.new

    words_by_user_and_type.each do |row|
      words_by_category[CommunityStatsService.category_for(row['entity_type'])] += row['words'].to_i
      writer_ids << row['user_id'].to_i
    end

    self.class.replace!(date, 'words', words_by_category)
    self.class.replace!(date, 'writers', { '' => writer_ids.size })

    month = date.beginning_of_month
    writer_ids.each_slice(5_000) do |ids|
      # insert_all skips rows that already exist (ON CONFLICT DO NOTHING / INSERT OR IGNORE)
      CommunityMonthlyWriter.insert_all(ids.map { |user_id| { month: month, user_id: user_id } })
    end
  end

  # One row per (user, entity type) with the positive words written on `date`.
  def words_by_user_and_type
    WordCountUpdate.connection.select_all(WordCountUpdate.sanitize_sql_array([<<~SQL, { date: date }]))
      SELECT user_id, entity_type, SUM(delta) AS words
      FROM (
        SELECT w.user_id, w.entity_type,
               COALESCE(w.word_count, 0) - COALESCE((
                 SELECT p.word_count
                 FROM word_count_updates p
                 WHERE p.entity_type = w.entity_type
                   AND p.entity_id = w.entity_id
                   AND p.for_date < w.for_date
                 ORDER BY p.for_date DESC
                 LIMIT 1
               ), 0) AS delta
        FROM word_count_updates w
        WHERE w.for_date = :date
      ) deltas
      WHERE delta > 0
      GROUP BY user_id, entity_type
    SQL
  end

  def roll_up_creations!
    day_start = date.in_time_zone.beginning_of_day
    day_end   = [day_start + 1.day, Time.current].min

    pages = self.class.page_classes.each_with_object({}) do |klass, counts|
      count = created_between(klass, day_start, day_end)
      counts[klass.name] = count if count > 0
    end
    self.class.replace!(date, 'pages_created', pages)

    self.class.replace!(date, 'new_writers', { '' => created_between(User, day_start, day_end) })
    self.class.replace!(date, 'forum_posts', {
      '' => Thredded::Post.where(moderation_state: 'approved', created_at: day_start...day_end).count
    })
    self.class.replace!(date, 'goals_completed', {
      '' => WritingGoal.where(completed_at: day_start...day_end).count
    })
  end

  # Rows of `klass` (respecting its default scope, e.g. soft deletes) created
  # in [from, to), found by id range rather than scanning created_at.
  def created_between(klass, from, to)
    first_id = @boundaries.first_id_at_or_after(klass, from)
    last_id  = @boundaries.first_id_at_or_after(klass, to)
    return 0 if first_id >= last_id

    klass.where(id: first_id...last_id).count
  end

  # Binary searches a table's primary key for the first id created at or after
  # a time. Assumes created_at grows with id, which holds for rows inserted by
  # the app; the occasional out-of-order row only nudges counts by one or two.
  # Results are memoized so consecutive days share their boundaries.
  class IdBoundaries
    def initialize
      @cache = {}
    end

    def first_id_at_or_after(klass, time)
      @cache[[klass.name, time.to_i]] ||= search(klass.unscoped, time)
    end

    private

    def search(scope, time)
      lo = scope.minimum(:id)
      return 0 if lo.nil?
      hi = scope.maximum(:id) + 1

      # Smallest x in [lo, hi] where the first row with id >= x was created at or after `time`
      while lo < hi
        mid = (lo + hi) / 2
        _, created_at = scope.where('id >= ?', mid).order(:id).limit(1).pluck(:id, :created_at).first
        if created_at && created_at >= time
          hi = mid
        else
          lo = mid + 1
        end
      end
      lo
    end
  end
end
