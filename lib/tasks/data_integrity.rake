namespace :data_integrity do
  desc "Make sure that all COMPLETED PaypalInvoices have a PageUnlockPromoCode associated with them"
  task completed_paypal_invoices: :environment do
    PaypalInvoice.where(status: "COMPLETED", page_unlock_promo_code_id: nil).find_each(&:generate_promo_code!)
  end

  desc "Ensure that all Premium subscribers are still Premium in Stripe"
  task subscription_synced_with_stripe: :environment do
    BillingPlan::PREMIUM_IDS.each do |billing_plan_id|
      active_billing_plan = BillingPlan.find(billing_plan_id)

      User.where(selected_billing_plan_id: billing_plan_id).find_each do |user|
        puts "Checking user ID #{user.id}"
        stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
        stripe_subscription = stripe_customer.subscriptions.data[0]

        # Go through each of the customer's subscription items and make sure their
        # current billing plan is included as one.
        should_downgrade_user = stripe_subscription.items.data.any? do |subscription_item|
          subscription_item.plan.id == active_billing_plan.stripe_plan_id
        end

        if should_downgrade_user
          SlackService.post('#subscription', "Automatically downgrading #{user} from #{active_billing_plan.stripe_plan_id}")
          # SubscriptionService.cancel_all_existing_subscriptions(user)
        end

        # Aggressively throttle (way too much) just to keep Stripe happy if we plan on doing
        # this for every user, every day.
        sleep 1
      end
    end
  end
end

