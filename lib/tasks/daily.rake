namespace :daily do
  desc "Delete thredded posts designated as spam"
  task clear_thredded_spam: :environment do
    Thredded::Post.where(moderation_state: "blocked").destroy_all
    Thredded::Topic.where(moderation_state: "blocked").destroy_all
  end

  desc "Run end-of-day-analytics reporter"
  task eod_analytics: :environment do
    EndOfDayAnalyticsJob.perform_now
  end
end
