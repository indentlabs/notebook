web: RAILS_GROUPS=web bundle exec puma -C config/puma.rb
worker: RAILS_GROUPS=worker bundle exec sidekiq -e production -C config/sidekiq.yml
