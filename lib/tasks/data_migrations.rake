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

  desc "Create a default 'English' language for all users"
  task create_english_language_for_all_users: :environment do
    User.all.each do |user|
      puts "Adding language to #{user.email.split('@').first}"
      user.languages.create(name: 'English')
    end
  end

  desc "Create a default 'Human' race for all users"
  task create_human_race_for_all_users: :environment do
    User.all.each do |user|
      puts "Adding human race to #{user.email.split('@').first}"
      user.races.where(name: 'Human').first_or_create
    end
  end

  desc "Add a billing plan for all users that don't already have one"
  task create_default_billing_plans: :environment do
    # todo: Grab the actual promised date/time here
    BETA_TESTERS_CUTOFF_DATE = "2016-01-01 00:00:00".to_time

    User.where(selected_billing_plan_id: nil).each do |user|
      puts "Setting default billing plan for #{user.email.split('@').first}@"

      beta_testers_plan  = BillingPlan.find_by(stripe_plan_id: 'free-for-life')
      standard_free_tier = BillingPlan.find_by(stripe_plan_id: 'starter')

      if beta_testers_plan.nil? || standard_free_tier.nil?
        raise "Couldn't find one of the necessary plans for this task -- check for free-for-life and starter stripe plan IDs"
      end

      if user.created_at < BETA_TESTERS_CUTOFF_DATE
        # If the user was created before the free-for-life beta testers promo, give them that plan
        puts "\tAdding to BETA TESTERS plan."
        user.update(selected_billing_plan_id: beta_testers_plan.id)
      else
        # Otherwise, give the user the default free plan
        puts "\tAdding to FREE TIER plan."
        user.update(selected_billing_plan_id: standard_free_tier.id)
      end

      # Since no active subscriptions is equivalent to the free tier, there's no need to build Subscriptions for these users
    end
  end
end