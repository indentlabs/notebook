namespace :data_migrations do
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

  desc "Migrate to the new attributes system"
  task migrate_all_users_to_new_attributes: :environment do
    require 'pry'

    # Create the default page categories/fields for all users for no-universe content
    Rails.application.config.content_types[:all].each do |content_class|
      content_class.create_default_page_categories_and_fields!(nil)
    end

    User.find_each do |user|
      puts "Migrating user #{user.id}" #if (user.id % 1000).zero?

      # If this user has any content with no universe AND has created any custom
      # fields, create a universe and put all non-universed content in it.
      orphan_content = user.content_without_universe
      if orphan_content.values.flatten.compact.any? && user.attribute_fields.any?
        universe = user.universes.create(name: 'Untitled')
        puts "  Created universe #{universe.id}"

        orphan_content.each do |klass, orphan_list|
          orphan_list.update_all(universe_id: universe.id)
        end
      end

      # Lets recapture any orphan content that's still not a universe, and assign
      # PageFieldValues for their existing (default) fields.
      orphan_content = user.content_without_universe
      orphan_content.each do |content_class, content_list|
        content_class_name = content_class.to_s.singularize
        content_class = content_class_name.titleize.constantize

        # Build a lookup table so we can translate a human-readable label back to the model column
        # it's stored in.
        class_schema = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_class_name}.yml"))
        field_column_by_label_lookup = {}
        class_schema.flat_map { |category, data| data[:attributes] }
          .each do |field|
            next if field.nil?
            next unless field[:label].present? && field[:name].present?
            field_column_by_label_lookup[field[:label]] = field[:name]
          end

        # Grab the human-readable list of attributes we want to fill data into
        fields_to_fill = PageCategory.where(universe: nil).where(content_type: content_class.name).flat_map(&:page_fields)

        content_list.each do |content|
          fields_to_fill.each do |field|
            field_column = field_column_by_label_lookup[field.label]

            # Custom attributes don't need copied over this way, and they're not gonna show up in the lookup table
            next if field_column.nil?

            field_value = content.send(field_column)

            PageFieldValue.find_or_create_by(
              page_field_id: field.id,
              page_id: content.id,
              value: field_value,
              user: content.user
            )
          end
        end
      end

      # Now that the user is guaranteed to have at least one universe, we want to
      # create default categories/fields for each of their universes.
      user.universes.each do |universe|
        puts "  Migrating universe #{universe.id}"
        Universe.create_default_page_categories_and_fields!(universe)

        puts "  Migrating pags in universe #{universe.id}"
        content_classes = Rails.application.config.content_types[:all_non_universe]
        content_classes.each do |content_class|
          content_class.create_default_page_categories_and_fields!(universe)
        end

        # For these default page categories and fields, we want to move over the
        # values we have currently stuck on models for "core" fields.
        content_classes.each do |content_class|
          content_class_name = content_class.name.downcase
          content_of_this_class = universe.send(content_class_name.pluralize)
          content_of_this_class.each do |content|

            # Build a lookup table so we can translate a human-readable label back to the model column
            # it's stored in.
            class_schema = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_class_name}.yml"))
            field_column_by_label_lookup = {}
            class_schema.flat_map { |category, data| data[:attributes] }
              .each do |field|
                next if field.nil?
                next unless field[:label].present? && field[:name].present?
                field_column_by_label_lookup[field[:label]] = field[:name]
              end

            # Grab the human-readable list of attributes we want to fill data into
            fields_to_fill = universe.page_categories.where(content_type: content_class.name).flat_map(&:page_fields)

            fields_to_fill.each do |field|
              field_column = field_column_by_label_lookup[field.label]

              # Custom attributes don't need copied over this way, and they're not gonna show up in the lookup table
              next if field_column.nil?

              field_value = content.send(field_column)

              # Transform links into bulleted lists of new links
              if field_value.is_a?(ActiveRecord::Associations::CollectionProxy)
                field_value = field_value.map { |related_object|
                  "[[#{related_object.class.name.downcase}-#{related_object.id}]]"
                }.join("\n")
              end

              PageFieldValue.find_or_create_by(
                page_field_id: field.id,
                page_id: content.id,
                value: field_value,
                user: content.user
              )
            end
          end
        end

        # We also want to migrate over any custom categories/attributes they've made
        user.attribute_categories.each do |custom_category|
          category = universe.page_categories.find_or_create_by(
            label: custom_category.label,
            icon: 'note_add',
            content_type: custom_category.entity_type.titleize
          )

          # And its fields...
          custom_category.attribute_fields.each do |custom_field|
            field = category.page_fields.find_or_create_by(
              label: custom_field.label
            )

            # And their values...
            custom_field.attribute_values.each do |custom_field_value|
              field.page_field_values.find_or_create_by(
                page_id: custom_field_value.entity_id,
                value: custom_field_value.value,
                user: universe.user
              )
            end
          end
        end
      end
    end
  end

  desc "Link transition to new attributes"
  task migrate_links_to_new_attributes: :environment do
    classes = Rails.application.config.content_relations
    classes.each do |content_class|
      puts "Migrating #{content_class} links"

      class_schema = YAML.load_file(Rails.root.join('config', 'attributes', "#{content_class.downcase}.yml"))
      field_category_by_name_lookup = {}
      field_column_by_label_lookup = {}
      class_schema.flat_map do |category, data|
        data[:attributes]
        [category, data[:attributes]]
      end.each do |category, field|
        next if field.nil?
        next unless field[:label].present? && field[:name].present?
        field_category_by_name_lookup[field[:name]] = category     # _[:fathers] = Family
        field_column_by_label_lookup[field[:label]] = field[:name] # _[:father]  =
      end

      relations = Rails.application.config.content_relations[content_class]
      relations.each do |relation, relation_data|
        # irb(main):009:0> Rails.application.config.content_relations['Character']['Fathership']
        # => {:with=>:fatherships,
        #     :related_class=>Fathership (call 'Fathership.connection' to establish a connection),
        #     :inverse_class=>"Character",
        #     :relation_text=>"father",
        #     :through_relation=>"father"}
        field_name = relation_data[:through_relation].pluralize # fathers

        User.all.find_each do |user|
          user.universes.each do |universe|
            # Find the category this goes in
            page_category = PageCategory.find_or_create_by(
              content_type: content_class,
              label: field_category_by_name_lookup[field_name]
            )

            # Find the field
            # Get the field value
            # Update it
          end

          # do the same for universe=nil
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
end
