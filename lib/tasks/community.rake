namespace :community do
  desc "Pre-compute the public /community page stats so visitors hit a warm cache"
  task warm_stats: :environment do
    started = Time.current
    stats = CommunityStatsService.new.warm!
    puts "Community stats warmed in #{(Time.current - started).round(1)}s " \
         "(#{stats.words_today} words today, #{stats.all_time_words} all time)."
  end
end
