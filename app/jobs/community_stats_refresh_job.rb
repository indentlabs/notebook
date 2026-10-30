# Re-rolls the last few days of anonymous community stats for /community.
# Run it hourly via cron (rake community:refresh); the page also enqueues it
# when it notices the numbers have gone stale.
class CommunityStatsRefreshJob < ApplicationJob
  queue_as :low_priority

  ENQUEUE_LOCK_KEY = 'community_stats/refresh_enqueued'

  # Enqueue at most one refresh per lock window, however many page views
  # notice stale numbers at once.
  def self.enqueue_unless_pending
    return unless Rails.cache.write(ENQUEUE_LOCK_KEY, true, unless_exist: true, expires_in: 15.minutes)
    perform_later
  end

  def perform
    CommunityStatsRollup.refresh_recent!
  ensure
    Rails.cache.delete(ENQUEUE_LOCK_KEY)
  end
end
