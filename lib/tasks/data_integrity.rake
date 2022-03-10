namespace :data_integrity do
  desc "Make sure there are no globally-linkable content pages"
  task remove_invalid_universe_content_pages: :environment do
    Rails.application.config.content_types[:all_non_universe].each do |type|
      type.where(universe_id: 0).update(universe_id: nil)
    end
  end

  desc "Make sure that all COMPLETED PaypalInvoices have a PageUnlockPromoCode associated with them"
  task completed_paypal_invoices: :environment do
    PaypalInvoice.where(status: "COMPLETED", page_unlock_promo_code_id: nil).find_each(&:generate_promo_code!)
  end

  desc "Ensure that all Premium subscribers are still Premium in Stripe"
  task subscription_synced_with_stripe: :environment do
    total_accounts_downgraded_this_run = 0

    synced_billing_plan_ids = BillingPlan::PREMIUM_IDS - [BillingPlan.find_by(stripe_plan_id: 'free-for-life').id]
    synced_billing_plan_ids.each do |billing_plan_id|
      active_billing_plan = BillingPlan.find(billing_plan_id)
      puts "Syncing billing plan #{active_billing_plan.stripe_plan_id} (#{active_billing_plan.id})"

      User.where(selected_billing_plan_id: billing_plan_id).find_each do |user|
        # puts "Checking user ID #{user.id}"
        stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
        stripe_subscription = stripe_customer.subscriptions.data[0]

        # Go through each of the customer's subscription items and make sure their
        # current billing plan is included as one.
        if stripe_subscription.nil?
          should_downgrade_user = true
        else
          should_downgrade_user = stripe_subscription.items.data.none? do |subscription_item|
            subscription_item.plan.id == active_billing_plan.stripe_plan_id
          end
        end

        if should_downgrade_user
          total_accounts_downgraded_this_run += 1
          puts "Downgrading user #{user.email} from #{active_billing_plan.stripe_plan_id} (last logged in #{user.last_sign_in_at.strftime("%F")})"

          SubscriptionService.cancel_all_existing_subscriptions(user)
          UnsubscribedMailer.unsubscribed(user).deliver_now! if Rails.env.production?
          SlackService.post('#subscriptions', "Automatically downgrading #{user.email} from #{active_billing_plan.stripe_plan_id}  (last logged in #{user.last_sign_in_at.strftime("%F")})")
        end

        # Aggressively throttle (too much) just to keep Stripe happy if we plan on doing
        # this for every user, every day.
        sleep 1
      end
    end

    SlackService.post('#subscriptions', total_accounts_downgraded_this_run.to_s + " total accounts downgraded from sync.")
  end

  desc "Clean up old orphaned links on content"
  task remove_orphaned_page_links: :environment do
    Rails.application.config.content_relations.each do |page_type, page_type_data|
      puts "Cleaning orphans for #{page_type}"
      page_type_data.each do |relation, relation_data|
        klass        = relation_data[:related_class]
        reference_id = relation_data[:through_relation].to_s + '_id'
        puts "Klass is #{klass.name}"
        puts "Reference ID is #{reference_id}"

        orphans = klass.where({"#{reference_id}": nil})
        puts "Orphans for relation #{relation_data[:with]}: #{orphans.count} -- deleting them all!"
        orphans.destroy_all
      end
    end
  end

  desc "Migrate old content and mark it as migrated once and for all"
  task migrate_old_content: :environment do
    RECORDS_TO_PROCESS = 300

    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    Rails.application.config.content_types[:all].each do |content_type|
      pages = content_type.where(columns_migrated_from_old_style: nil).limit(RECORDS_TO_PROCESS)
      puts "Migrating #{content_type.name} (#{pages.count} pages)"

      pages.each do |page|
        puts "Hey, this page shouldn't be here!" if page.columns_migrated_from_old_style == true
        TemporaryFieldMigrationService.migrate_fields_for_content(page, page.user, force: true)

        page.update_column(:columns_migrated_from_old_style, true) unless page.reload.columns_migrated_from_old_style == true
      end
    end

    puts "Pages remaining to migrate: "
    Rails.application.config.content_types[:all].each do |content_type|
      count = content_type.where(columns_migrated_from_old_style: nil).count
      puts "#{content_type.name}: #{count} (#{content_type.where.not(columns_migrated_from_old_style: nil).count} migrated)"
    end

    ActiveRecord::Base.logger = old_logger
  end

  desc "Migrate old content per user"
  task migrate_old_content_per_user: :environment do
    START_ID = 1
    USERS_TO_PROCESS = 500

    users = User.where(id: START_ID..(START_ID+USERS_TO_PROCESS))
    puts "Processing #{users.count} users"

    users.each do |user|
      TemporaryFieldMigrationService.migrate_all_content_for_user(user)
    end

  end

  desc "Ensure all users have the correct upload bandwidth amounts"
  task correct_bandwidths: :environment do
    base_bandwidth = User.new.upload_bandwidth_kb           #     50_000
    premium_bonus  = BillingPlan.find(4).bonus_bandwidth_kb #  9_950_000
    premium_total  = base_bandwidth + premium_bonus         # 10_000_000
    referral_bonus = 100_000 # per referral

    puts "Disabling SQL logging"
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    User.find_each do |user|
      max_bandwidth  = BillingPlan::PREMIUM_IDS.include?(user.selected_billing_plan_id) ? premium_total : base_bandwidth
      referral_bonus = user.referrals.count * referral_bonus
      used_bandwidth = user.image_uploads.sum(:src_file_size)

      remaining_bandwidth = max_bandwidth + referral_bonus - used_bandwidth
      if user.upload_bandwidth_kb != remaining_bandwidth
        puts "Correcting user #{user.id} bandwidth: #{user.upload_bandwidth_kb} --> #{remaining_bandwidth}"
        # user.update(upload_bandwidth_kb: remaining_bandwidth)
      end
    end

    puts "Re-enabling SQL logging"
    ActiveRecord::Base.logger = old_logger
  end
end

