# One pre-aggregated, anonymous community metric for one day.
# See CommunityStatsRollup (writer) and CommunityStatsService (reader).
class CommunityDailyStat < ApplicationRecord
  METRICS = %w(
    words writers writers_last_hour all_time_writers
    pages_created new_writers goals_completed forum_posts
  ).freeze

  validates :metric, inclusion: { in: METRICS }
end
