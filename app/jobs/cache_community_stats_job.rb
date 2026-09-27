# Warms the CommunityStatsService cache so visitors to /community never pay
# for the (fairly heavy) community-wide word count aggregation.
class CacheCommunityStatsJob < ApplicationJob
  queue_as :low_priority

  def perform
    CommunityStatsService.new.warm!
  end
end
