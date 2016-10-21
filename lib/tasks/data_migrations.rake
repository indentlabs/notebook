namespace :data_migrations do
  desc "Create a race for each user, for each of their characters with a `race` value"

  task create_races_from_character_races: :environment do
    User.all.each do |user|
      puts "Migrating user #{user.email.split('@').first}..."

      user.characters.where.not(race: "").each do |character|
        race = character.race

        puts "\tCreating race #{race}"

        new_race = user.races.where(name: race).first_or_create
        character.races << new_race
      end
    end

    puts " All done now!"
  end
end