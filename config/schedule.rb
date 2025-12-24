# This file is for the whenever gem (optional)
# To use: add `gem 'whenever', require: false` to Gemfile
# Then run: whenever --update-crontab

# If not using whenever gem, add this manually to crontab with: crontab -e
# 0 3 * * * cd /var/www/notebook && RAILS_ENV=production /home/ubuntu/.rbenv/shims/bundle exec rake cache:clear_old >> /var/www/notebook/log/cache_cleanup.log 2>&1

# Clean up old cache files daily at 3 AM
every 1.day, at: '3:00 am' do
  rake "cache:clear_old"
end

# Show cache stats weekly (optional - for monitoring)
every :sunday, at: '2:00 am' do
  rake "cache:stats"
end