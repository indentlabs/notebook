class SubscriptionsController < ApplicationController
  def new
    # We only support a single billing plan right now, so just grab the first one. If they don't have an active plan,
    # we also treat them as if they have a Starter plan.
    @active_billing_plan = current_user.active_billing_plans.first || BillingPlan.find_by(stripe_plan_id: 'starter')

    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    @stripe_invoices = @stripe_customer.invoices # makes a second call to Stripe
  end

  def show
  end

  def change
    new_plan_id = params[:stripe_plan_id]
    possible_plan_ids = BillingPlan.where(available: true).map(&:stripe_plan_id)

    raise "Invalid billing plan ID: #{new_plan_id}" unless possible_plan_ids.include? new_plan_id

    # Fetch current subscription
    stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
    stripe_subscription = stripe_customer.subscriptions.data[0]

    # If the user already has a payment method on file, change their plan and add a new subscription
    if stripe_customer.sources.total_count > 0
      # Cancel any active subscriptions, since we're changing plans
      current_user.active_subscriptions.each do |subscription|
        subscription.update(end_date: Time.now)
      end

      # Change subscription plan if they already have a payment method on file
      stripe_subscription.plan = new_plan_id
      begin
        stripe_subscription.save
      rescue Stripe::CardError => e
        flash[:alert] = "We couldn't upgrade you to Premium because #{e.message.downcase} Please double check that your information is correct."
        return redirect_to :back
      end

      new_billing_plan = BillingPlan.find_by(stripe_plan_id: new_plan_id, available: true)
      current_user.selected_billing_plan_id = new_billing_plan.id
      current_user.save

      Subscription.create(
        user: current_user,
        billing_plan: new_billing_plan,
        start_date: Time.now,
        end_date: Time.now.end_of_day + 31.days
      )

      redirect_to subscription_path
    else
      # If they don't have a payment method on file, redirect them to collect one
      redirect_to payment_info_path(plan: new_plan_id)
    end
  end

  # This isn't actually needed since we change the paid plan to the free plan, but will be needed when we
  # add a way to deactivate/delete accounts, so the logic is here for when it's needed.
  # def cancel
  #   # Fetch the user's current subscription
  #   stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
  #   stripe_subscription = stripe_customer.subscriptions.data[0]

  #   # Cancel it at the end of its effective period on Stripe's end, so they don't get rebilled
  #   stripe_subscription.delete(at_period_end: true)
  # end

  def information
    @selected_plan = BillingPlan.find_by(stripe_plan_id: params['plan'])
  end

  def information_change
    valid_token = params[:stripeToken]
    raise "Invalid token" if valid_token.nil?

    raise current_user.inspect

    stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
    stripe_customer.sources.create(source: valid_token)

    # After saving the user's payment method, move them over to the associated billing plan
    new_billing_plan = BillingPlan.find_by(stripe_plan_id: params[:stripe_plan_id], available: true)
    current_user.selected_billing_plan_id = new_billing_plan.id
    current_user.save

    redirect_to subscription_path
  end

end

# tok_19fCuyDtQxm4tDEkGSLIJ4Vx