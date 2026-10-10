namespace :community do
  desc "Refresh the last few days of /community stats (run hourly from cron)"
  task refresh: :environment do
    started = Time.current
    CommunityStatsRollup.refresh_recent!
    puts "Community stats refreshed in #{(Time.current - started).round(1)}s."
  end

  desc "Fill /community stats for past days: rake community:backfill[2016-01-01,2026-09-24] (defaults: first tracked day .. 3 days ago)"
  task :backfill, [:from, :to] => :environment do |_, args|
    from = args[:from].present? ? Date.parse(args[:from]) : WordCountUpdate.minimum(:for_date)
    to   = args[:to].present?   ? Date.parse(args[:to])   : Date.current - 3.days
    abort "Nothing to backfill." if from.nil? || from > to

    started = Time.current
    (from..to).each do |date|
      day_started = Time.current
      CommunityStatsRollup.new(date).run!
      CommunityStatsRollup.roll_up_pages_edited!(date) if date == date.end_of_month || date == to
      puts "#{date}: #{(Time.current - day_started).round(2)}s"
    end
    CommunityStatsRollup.record_point_in_time_metrics!(Date.current)
    puts "Backfilled #{(to - from).to_i + 1} days in #{((Time.current - started) / 60).round(1)} minutes."
  end
end
