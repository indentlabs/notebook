# frozen_string_literal: true

# Computes the anonymous community stats for one day and stores them in
# CommunityDailyStat / CommunityMonthlyWriter, which CommunityStatsService
# reads to render the public /community page.
#
# Word counts are the only expensive part: each day reads just that day's
# word_count_updates rows (via the for_date index), and each row's previous
# record is a single backwards probe on the (entity_type, entity_id, for_date)
# unique index, so a day costs the same regardless of total table size.
#
# Pages created, sign-ups, forum posts and goals come from the existing
# EndOfDayAnalyticsReport rows instead of being counted again here.
#
# Recent days are refreshed regularly (see CommunityStatsRefreshJob), each
# finished day is finalized by EndOfDayAnalyticsJob, and history is filled
# once with `rake community:backfill`.
class CommunityStatsRollup
  # Re-rolls the last few days (writers in time zones behind the server are
  # still adding to "yesterday"), plus the point-in-time metrics.
  def self.refresh_recent!(today: Date.current)
    ((today - 2.days)..today).each { |date| new(date).run! }

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

  def initialize(date)
    @date = date
  end

  def run!
    roll_up_words!
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
  # (On Postgres, OFFSET 0 keeps the planner from inlining the subquery, which
  # would run each previous-record probe twice: once for the filter, once for the sum.)
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
        #{postgres? ? 'OFFSET 0' : ''}
      ) deltas
      WHERE delta > 0
      GROUP BY user_id, entity_type
    SQL
  end

  def postgres?
    WordCountUpdate.connection.adapter_name.downcase.include?('postg')
  end
end
