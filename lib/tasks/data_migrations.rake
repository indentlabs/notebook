namespace :data_migrations do
  desc "Create PageReferences for all the old content linkers"
  task create_content_linker_page_references: :environment do
    start_time = DateTime.current
    puts "Starting the long migration!"

    Rails.application.config.content_relations.each do |page_type, relation_list|
      time_elapsed = DateTime.current - start_time
      puts "Starting #{page_type} link migrations (T+#{time_elapsed.to_i})"

      relation_list.each do |relation_name, relation_params|
        link_class = relation_params[:related_class] # Fathership

        referencing_page_type = relation_params[:inverse_class]
        puts relation_params[:through_relation]
        puts relation_params.inspect
        puts link_class.reflect_on_association(relation_params[:through_relation]).inspect

        referenced_page_type = nil
        if relation_params[:through_relation] == :deity && referencing_page_type == "Religion"
          referenced_page_type = link_class.reflect_on_association(:deity_character).class_name
        else
          referenced_page_type = link_class.reflect_on_association(relation_params[:through_relation]).class_name
        end

        puts "  Creating references for #{link_class.count} #{relation_name} links"
        link_class.find_each do |link|
          referencing_page = link.send(referencing_page_type.downcase)
          referenced_page  = link.send(relation_params[:through_relation])
          
          if (referencing_page.nil? || referenced_page.nil?)
            # Don't do anything here -- one of the pages has since been deleted
            puts "    Skipping a deleted-page reference"
            next
          end

          categories_for_this_page_type_and_user = AttributeCategory.where(
            entity_type: referencing_page_type.downcase,
            user_id:     referencing_page.user_id
          ).pluck(:id)

          # We also need to find the associated AttributeField (OMG) to make sure we
          # tie the new references to that field.
          attribute_field = AttributeField.where(
            attribute_category_id: categories_for_this_page_type_and_user,
            user_id:               referencing_page.user_id,
            field_type:            'link',
            old_column_source:     relation_params[:through_relation].pluralize
          )

          if attribute_field.count > 1
            puts "Ambiguous field"
            require 'pry'
            binding.pry
          end

          attribute_field = attribute_field.first
          if attribute_field.nil?
            # Field has been deleted....?
            next
          end

          # Debug
          puts "    Referencing page: #{referencing_page_type}-#{referencing_page.id}"
          puts "    Referenced page:  #{referenced_page_type}-#{referenced_page.id}"
          puts "    Attribute field:  #{attribute_field.label} (#{attribute_field.id})"
        end
      end
    end

  end

  desc "Create activators for all used content types for all users"
  task create_content_type_activators: :environment do
    default_content_types = [
      Universe, Character, Location, Item
    ]
    variable_content_types = [
      Creature, Flora, Group, Language, Magic, Race, Religion, Scene
    ]

    User.where('id > 20000').find_each do |user|
      puts "Creating activators for user #{user.id}" if (user.id % 1000).zero?

      # These are default, but users can turn them off later
      default_content_types.each do |content_type|
        user.user_content_type_activators.find_or_create_by(content_type: content_type.name)
      end

      # Only turn these ones on if users have any existing content for them
      variable_content_types.each do |content_type|
        existing_content = user.send(content_type.name.downcase.pluralize).count > 0

        if existing_content
          user.user_content_type_activators.find_or_create_by(content_type: content_type.name)
        end
      end
    end
  end

  desc "Initialize Stripe customer ID for all users without one already"
  task initialize_stripe_customers: :environment do
    User.where(stripe_customer_id: nil).each do |user|
      puts "Initializing Stripe Customer for user #{user.email.split('@').first}@"
      user.initialize_stripe_customer
    end
  end

  desc "Add a billing plan for all users that don't already have one"
  task create_default_billing_plans: :environment do
    # todo: Grab the actual promised date/time here
    BETA_TESTERS_CUTOFF_DATE = "2016-11-01 08:00:00".to_time # October 1 through November 1, 2016, with 8 hours wiggle room

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

  desc "Add developer billing plans"
  task create_developer_billing_plans: :environment do
    # TODO
  end

  desc "Add bandwidth bonuses to billing plans"
  task billing_plan_bandwidths: :environment do
    puts "Updating bandwidths for all billing plans"
    BillingPlan.find_by(stripe_plan_id: 'starter').update(bonus_bandwidth_kb: 50_000)
    BillingPlan.find_by(stripe_plan_id: 'free-for-life').update(bonus_bandwidth_kb: 250_000)
    BillingPlan.find_by(stripe_plan_id: 'early-adopters').update(bonus_bandwidth_kb: 950_000)
    BillingPlan.find_by(stripe_plan_id: 'premium').update(bonus_bandwidth_kb: 950_000)
    puts "Done"
  end

  desc "Add bandwidth counts to existing users"
  task initialize_user_bandwidths: :environment do
    starter_id = BillingPlan.find_by(stripe_plan_id: 'starter').id
    beta_id = BillingPlan.find_by(stripe_plan_id: 'free-for-life').id
    premium_ids = [
      BillingPlan.find_by(stripe_plan_id: 'early-adopters').id,
      BillingPlan.find_by(stripe_plan_id: 'premium').id
    ]

    # Premium
    puts "Setting premium users to 10GB"
    puts User.where(selected_billing_plan_id: premium_ids).update_all(upload_bandwidth_kb: 10_000_000) # 10GB

    # Starter
    puts "Setting starter users to 50MB"
    puts User.where(selected_billing_plan_id: nil).update_all(upload_bandwidth_kb: 50_000) # 50MB
    puts User.where(selected_billing_plan_id: starter_id).update_all(upload_bandwidth_kb: 50_000) # 50MB

    # Beta
    puts "Setting beta users to 250MB"
    puts User.where(selected_billing_plan_id: beta_id).update_all(upload_bandwidth_kb: 250_000) # 250MB
  end

  desc "Create default attribute categories for a bundle of users with 0 categories created"
  task create_default_attribute_categories: :environment do
    puts "Turning off SQL logs"
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    to_migrate = User.all.pluck(:id) - AttributeCategory.pluck(:user_id).uniq

    users_migrated = 1
    to_migrate.first(100).each do |user_id|
        user = User.find(user_id)
        puts "Migrating user ##{user_id} #{user.email} (#{users_migrated}/#{to_migrate.count})"
        
        ActiveRecord::Base.transaction do 
            Rails.application.config.content_types[:all].each do |content_type|
                puts "\tMigrating #{content_type.name}..."
                content_type.create_default_attribute_categories(user)
            end
        end

        users_migrated += 1
    end

    puts "Turning SQL logging back on"
    ActiveRecord::Base.logger = old_logger
  end
end
