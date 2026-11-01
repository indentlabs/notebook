namespace :smoke do
  # Sets up the account script/smoke_check.rb signs in as, with a little content
  # of each core kind so the signed-in crawl reaches real pages. Run it once in
  # each environment (staging, production); running it again is harmless.
  #
  #   SMOKE_EMAIL=... SMOKE_PASSWORD=... bin/rails smoke:setup_account
  #
  # The credentials come from the environment because this repository is
  # public: never commit them. Keep them wherever the deploy secrets live.
  #
  # Everything the account owns is private, so none of it shows up in public
  # listings, search or the stream.
  desc 'Create or update the account script/smoke_check.rb signs in as'
  task setup_account: :environment do
    email    = ENV['SMOKE_EMAIL'].to_s.strip
    password = ENV['SMOKE_PASSWORD'].to_s
    abort 'Set SMOKE_EMAIL and SMOKE_PASSWORD.' if email.empty? || password.empty?

    user = User.with_deleted.find_or_initialize_by(email: email)
    user.restore if user.respond_to?(:deleted?) && user.deleted?
    created = user.new_record?
    user.assign_attributes(name: 'Smoke Test', password: password, password_confirmation: password)
    user.time_zone ||= 'UTC'
    user.save!

    universe = Universe.find_or_create_by!(user: user, name: 'Smoke Test Universe') do |u|
      u.privacy     = 'private'
      u.description = 'Used by script/smoke_check.rb to check pages after a deploy.'
    end

    [Character, Location, Item].each do |klass|
      klass.find_or_create_by!(user: user, universe: universe, name: "Smoke Test #{klass.name}") do |page|
        page.privacy = 'private'
      end
    end

    Document.find_or_create_by!(user: user, title: 'Smoke Test Document') do |document|
      document.universe = universe
      document.privacy  = 'private'
      document.body     = '<p>Smoke Test Character walked into Smoke Test Location.</p>'
    end

    Timeline.find_or_create_by!(user: user, name: 'Smoke Test Timeline') do |timeline|
      timeline.universe = universe
      timeline.privacy  = 'private'
    end

    puts "#{created ? 'Created' : 'Updated'} smoke test account #{email} (user ##{user.id})."
    puts 'Check it with: SMOKE_EMAIL=... SMOKE_PASSWORD=... ruby script/smoke_check.rb <site url>'
  end
end
