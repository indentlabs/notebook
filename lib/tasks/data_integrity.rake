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

  desc "Report Premium subscribers who no longer look Premium in Stripe. " \
       "Report-only by default; APPLY=1 downgrades them (subject to a safety limit)."
  task subscription_synced_with_stripe: :environment do
    # This task once mass-downgraded nearly every paying user because it misread
    # Stripe (a dead `customer.subscriptions` read made everyone look unsubscribed).
    # So: it only reports unless APPLY=1, it never treats a Stripe error as "no
    # subscription", and it decides whether to abort BEFORE touching anyone.
    apply = ENV['APPLY'] == '1'

    synced_billing_plan_ids = BillingPlan::PREMIUM_IDS - [BillingPlan.find_by(stripe_plan_id: 'free-for-life').id]
    synced_user_count = User.where(selected_billing_plan_id: synced_billing_plan_ids).count
    downgrade_limit = [(synced_user_count * 0.05).ceil, 10].min

    mismatches = []
    stripe_errors = []

    synced_billing_plan_ids.each do |billing_plan_id|
      active_billing_plan = BillingPlan.find(billing_plan_id)
      puts "Syncing billing plan #{active_billing_plan.stripe_plan_id} (#{active_billing_plan.id})"

      User.where(selected_billing_plan_id: billing_plan_id).find_each do |user|
        # Check every billable subscription the customer has, not just the first
        # one, and list them directly: retrieved Customer objects no longer
        # include their subscriptions on current Stripe API versions.
        begin
          stripe_subscriptions = SubscriptionService.billable_stripe_subscriptions(user.stripe_customer_id)
        rescue Stripe::StripeError => e
          stripe_errors << user
          puts "Stripe error for user #{user.id}, skipping: #{e.class}: #{e.message}"
          next
        end

        on_plan = stripe_subscriptions.any? do |stripe_subscription|
          SubscriptionService.subscription_price_ids(stripe_subscription).include?(active_billing_plan.stripe_plan_id)
        end

        unless on_plan
          mismatches << [user, active_billing_plan]
          puts "Mismatch: user #{user.email} is on #{active_billing_plan.stripe_plan_id} locally but not in Stripe " \
               "(Stripe subscriptions: #{stripe_subscriptions.map { |s| "#{s.id}[#{s.status}]" }.join(', ').presence || 'none'})"
        end

        # Aggressively throttle (too much) just to keep Stripe happy if we plan on doing
        # this for every user, every day.
        sleep 1 unless Rails.env.test?
      end
    end

    summary = "Stripe sync: #{mismatches.length} of #{synced_user_count} Premium users not Premium in Stripe; #{stripe_errors.length} Stripe errors."
    puts summary

    unless apply
      SlackService.post('#subscriptions', "#{summary} Report only; nobody was downgraded.")
      next
    end

    if stripe_errors.any? || mismatches.length > downgrade_limit
      SlackService.post('#subscriptions', "#{summary} ABORTED: exceeds the safety limit of #{downgrade_limit} (or had Stripe errors); nobody was downgraded.")
      abort "ABORTING: #{summary} Safety limit is #{downgrade_limit} with zero Stripe errors. " \
            "This usually means we're misreading Stripe rather than that these users churned. Nobody was downgraded."
    end

    mismatches.each do |user, active_billing_plan|
      puts "Downgrading user #{user.email} from #{active_billing_plan.stripe_plan_id}"
      SubscriptionService.cancel_all_existing_subscriptions(user)
      UnsubscribedMailer.unsubscribed(user).deliver_now! if Rails.env.production?
      SlackService.post('#subscriptions', "Automatically downgrading #{user.email} from #{active_billing_plan.stripe_plan_id}")
    end

    SlackService.post('#subscriptions', mismatches.length.to_s + " total accounts downgraded from sync.")
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

