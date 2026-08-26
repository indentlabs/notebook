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

  desc "Ensure that all Premium subscribers are still Premium in Stripe. " \
       "Set DRY_RUN=1 to report without downgrading anyone."
  task subscription_synced_with_stripe: :environment do
    dry_run = ENV['DRY_RUN'] == '1'
    total_accounts_downgraded_this_run = 0

    # Safety valve: if we'd downgrade a large share of paying users in a single
    # run, that is far more likely to mean we're misreading Stripe than that
    # everybody churned at once. (A dead `customer.subscriptions` read did
    # exactly this once already.) Bail out instead of mass-downgrading.
    premium_user_count = User.where(selected_billing_plan_id: BillingPlan::PREMIUM_IDS).count
    downgrade_limit = [(premium_user_count * 0.2).ceil, 10].max

    synced_billing_plan_ids = BillingPlan::PREMIUM_IDS - [BillingPlan.find_by(stripe_plan_id: 'free-for-life').id]
    synced_billing_plan_ids.each do |billing_plan_id|
      active_billing_plan = BillingPlan.find(billing_plan_id)
      puts "Syncing billing plan #{active_billing_plan.stripe_plan_id} (#{active_billing_plan.id})"

      User.where(selected_billing_plan_id: billing_plan_id).find_each do |user|
        # puts "Checking user ID #{user.id}"
        # Check every billable subscription the customer has, not just the first
        # one, and list them directly: retrieved Customer objects no longer
        # include their subscriptions on current Stripe API versions.
        stripe_subscriptions = SubscriptionService.billable_stripe_subscriptions(user.stripe_customer_id)
        should_downgrade_user = stripe_subscriptions.none? do |stripe_subscription|
          SubscriptionService.subscription_price_ids(stripe_subscription).include?(active_billing_plan.stripe_plan_id)
        end

        if should_downgrade_user
          total_accounts_downgraded_this_run += 1
          puts "#{dry_run ? 'Would downgrade' : 'Downgrading'} user #{user.email} from #{active_billing_plan.stripe_plan_id} (last logged in #{user.last_sign_in_at.strftime("%F")})"

          if total_accounts_downgraded_this_run > downgrade_limit
            abort "ABORTING: #{total_accounts_downgraded_this_run} of #{premium_user_count} premium users looked unsubscribed on Stripe, which exceeds the safety limit of #{downgrade_limit}. This usually means we're misreading Stripe rather than that these users actually churned. Investigate before re-running."
          end

          unless dry_run
            SubscriptionService.cancel_all_existing_subscriptions(user)
            UnsubscribedMailer.unsubscribed(user).deliver_now! if Rails.env.production?
            SlackService.post('#subscriptions', "Automatically downgrading #{user.email} from #{active_billing_plan.stripe_plan_id}  (last logged in #{user.last_sign_in_at.strftime("%F")})")
          end
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

  desc "Remove orphan page references"
  task remove_orphan_page_references: :environment do
    PageReference.find_each do |reference|
      if reference.referencing_page.nil?
        puts "Deleting reference #{reference.id}"
        reference.destroy
        next
      end

      if reference.referenced_page.nil?
        puts "Deleting reference #{reference.id}"
        reference.destroy
        next
      end
    end
  end

  desc "Ensure all users have the correct upload bandwidth amounts"
  task correct_bandwidths: :environment do
    puts "Disabling SQL logging"
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    # For the sake of minimizing db updates while blazing through all users,
    # we ignore a small amount (1kb) of difference between saved bandwidth
    # and calculated bandwidth. Users should never be more than 1kb off though.
    byte_lenience = 1000

    User.find_each do |user|
      correct_bandwidth = SubscriptionService.recalculate_bandwidth_for(user)

      difference = user.upload_bandwidth_kb - correct_bandwidth
      if difference.abs >  byte_lenience
        # puts "Correcting user #{user.id} bandwidth: #{user.upload_bandwidth_kb} --> #{correct_bandwidth}"
        user.update(upload_bandwidth_kb: correct_bandwidth)
      end
    end

    puts "Re-enabling SQL logging"
    ActiveRecord::Base.logger = old_logger
  end
end

