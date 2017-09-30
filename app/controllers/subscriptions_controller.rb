class SubscriptionsController < ApplicationController
  protect_from_forgery except: :stripe_webhook

  def new
    return redirect_to new_user_session_path, notice: t(:no_do_permission) unless user_signed_in?

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'viewed billing page', {
      'current billing plan': current_user.selected_billing_plan_id,
      'content count': current_user.content_count
    }) if Rails.env.production?

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
    raise "Invalid billing plan ID: #{new_plan_id}" unless SubscriptionService.available_plan?(new_plan_id)

    # Grab the stripe object once upfront, since it's an external API call
    stripe_customer = SubscriptionService.stripe_customer_object_for(current_user)

    # If a user is moving to premium, make sure they have a card on file
    if SubscriptionService.PAID_PREMIUM_PLAN_IDS.include?(new_plan_id) && !SubscriptionService.has_card_on_file_for?(stripe_customer)
      return redirect_to payment_info_path(plan: new_plan_id)
    end

    # Make the plan transition
    success = SubscriptionService.transition_plan(
      user: current_user,
      old_plan: BillingPlan.find(current_user.selected_billing_plan_id)
      new_plan: BillingPlan.find(new_plan_id),
      stripe_object: stripe_customer
    )

    if success
      flash[:notice] = "You have successfully changed your plan to #{new_billing_plan.name}."
    else
      # error-specific messages are set in SubscriptionService, so we don't need to add a flash message here
    end

    redirect_to subscription_path
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
    @selected_plan = BillingPlan.find_by(stripe_plan_id: params['plan'], available: true)
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'viewed payment method page', {
      'current billing plan': current_user.selected_billing_plan_id,
      'content count': current_user.content_count
    }) if Rails.env.production?
  end

  def information_change
    # No idea why current_user is nil for this endpoint (maybe CSRF isn't passing through correctly?) but
    # calling authenticate_user! here reauths the user and sets current_user
    authenticate_user!

    valid_token = params[:stripeToken]
    raise "Invalid token" if valid_token.nil?

    stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
    stripe_subscription = stripe_customer.subscriptions.data[0]
    begin
      # Delete all existing payment methods to have our new one "replace" them
      stripe_customer.sources.each do |payment_method|
        payment_method.delete
      end

      # Add the new card info
      stripe_customer.sources.create(source: valid_token)
    rescue Stripe::CardError => e
      flash[:alert] = "We couldn't save your payment information because #{e.message.downcase} Please double check that your information is correct."
      return redirect_to :back
    end

    notice = []

    # After saving the user's payment method, move them over to the associated billing plan
    new_billing_plan = BillingPlan.find_by(stripe_plan_id: params[:plan], available: true)
    if new_billing_plan
      old_billing_plan = SubscriptionService.current_billing_plan_for(current_user)
      current_user.selected_billing_plan_id = new_billing_plan.id

      # Remove any bonus bandwidth our old plan granted
      current_user.upload_bandwidth_kb -= old_billing_plan.bonus_bandwidth_kb

      # Add any bonus bandwidth our new plan grants
      current_user.upload_bandwidth_kb += new_billing_plan.bonus_bandwidth_kb

      current_user.save

      stripe_subscription.plan = new_billing_plan.stripe_plan_id
      begin
        stripe_subscription.save
      rescue Stripe::CardError => e
        flash[:alert] = "We couldn't upgrade you to Premium because #{e.message.downcase} Please double check that your information is correct."
        return redirect_to :back
      end

      # End all currently-active subscriptions
      SubscriptionService.end_all_active_subscriptions_for current_user

      # If this is the first time this user is subscribing to Premium, gift them (and their referrer, if applicable) feature votes and space
      existing_premium_subscriptions = current_user.subscriptions.where(billing_plan_id: [2, 3, 4, 5, 6])
      if existing_premium_subscriptions.none?
        SubscriptionService.add_first_time_premium_benefits_to(current_user)
        SubscriptionService.add_referral_benefits_to(
          referree: current_user
          referrer: current_user.referrer || current_user
        )
      end

      # And create a subscription for them for the current plan
      Subscription.create(
        user: current_user,
        billing_plan: new_billing_plan,
        start_date: Time.now,
        end_date: Time.now.end_of_day + 31.days
      )

      SubscriptionService.report_subscription_change_to_slack current_user, old_billing_plan, new_billing_plan

      notice << "you have been successfully upgraded to #{new_billing_plan.name}"
    end

    notice << "Your payment method has been successfully saved"

    flash[:notice] = "#{notice.reverse.to_sentence}."
    redirect_to subscription_path
  end

  def delete_payment_method
    stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
    stripe_subscription = stripe_customer.subscriptions.data[0]

    stripe_customer.sources.each do |payment_method|
      payment_method.delete
    end

    notice = ['Your payment method has been successfully deleted.']

    if stripe_subscription.plan.id != 'starter'
      # Cancel the user's at the end of its effective period on Stripe's end, so they don't get rebilled
      stripe_subscription.delete(at_period_end: true)

      active_billing_plan = BillingPlan.find_by(stripe_plan_id: stripe_subscription.plan.id)
      if active_billing_plan
        notice << "Your #{active_billing_plan.name} subscription will end on #{Time.at(stripe_subscription.current_period_end).strftime('%B %d')}."
      end
    end

    flash[:notice] = notice.join ' '
    redirect_to :back
  end

  def stripe_webhook
    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'stripe webhook') if Rails.env.production?
    #todo handle webhooks
  end
end
