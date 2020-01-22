namespace :data_integrity do
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

          SlackService.post('#subscriptions', "Automatically downgrading #{user.email} from #{active_billing_plan.stripe_plan_id}  (last logged in #{user.last_sign_in_at.strftime("%F")})")
          SubscriptionService.cancel_all_existing_subscriptions(user)
        end

        # Aggressively throttle (too much) just to keep Stripe happy if we plan on doing
        # this for every user, every day.
        sleep 1
      end
    end

    SlackService.post('#subscriptions', total_accounts_downgraded_this_run.to_s + " total accounts downgraded from sync.")
  end
end

