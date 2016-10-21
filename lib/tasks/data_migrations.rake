namespace :data_migrations do
  desc "Create a race for each user, for each of their characters with a `race` value"

  task create_races_from_character_races: :environment do
    users.each do |user|
      puts "Migrating user #{user.email.split('@').first}...""


    end

    users = User.confirmed
    puts "Going to update #{users.count} users"

    ActiveRecord::Base.transaction do
      users.each do |user|
        user.mark_newsletter_received!
        print "."
      end
    end

    puts " All done now!"
  end
end