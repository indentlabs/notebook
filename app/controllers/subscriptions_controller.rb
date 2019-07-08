class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  protect_from_forgery except: :stripe_webhook

  # General billing page
  def new
    @sidenav_expansion = 'my account'
    
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
    possible_plan_ids = SubscriptionService.available_plans.pluck(:stripe_plan_id)

    unless possible_plan_ids.include?(new_plan_id)
      raise "Invalid billing plan ID: #{new_plan_id}"
    end

    result = move_user_to_plan_requested(new_plan_id)

    if result == :payment_method_needed
      redirect_to payment_info_path(plan: new_plan_id)
    elsif result == :failed_card
      return
    else
      redirect_to(subscription_path, notice: "Your plan was successfully changed.")
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

  # Billing information page
  def information
    @selected_plan = BillingPlan.find_by(stripe_plan_id: params['plan'], available: true)
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'viewed payment method page', {
      'current billing plan': current_user.selected_billing_plan_id,
      'content count': current_user.content_count
    }) if Rails.env.production?
  end

  # Save a payment method
  def information_change
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
      return redirect_back fallback_location: payment_info_path
    end

    new_plan_id = params[:plan]
    result = move_user_to_plan_requested(new_plan_id) if new_plan_id

    if result == :payment_method_needed
      redirect_to payment_info_path(plan: new_plan_id)
    elsif result == :failed_card
      return
    else
      redirect_to(subscription_path, notice: 'Your plan was successfully changed.')
    end

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
    redirect_back fallback_location: subscription_path
  end

  def stripe_webhook
    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'stripe webhook') if Rails.env.production?
    #todo handle webhooks :(
  end

  def redeem_code
    code = PageUnlockPromoCode.find_by(code: params.require(:promotional_code).permit(:promo_code)[:promo_code])

    if code.nil?
      redirect_back(fallback_location: subscription_path, alert: "This isn't a valid promo code.")
      return
    end

    if code.uses_remaining < 1
      redirect_back(fallback_location: subscription_path, alert: "This promo code has expired!")
      return
    end

    if code.users.include?(current_user)
      redirect_back(fallback_location: subscription_path, alert: "You've already activated this promo code!")
      return
    end      

    # If it looks like a valid code and quacks like a valid code, it's probably a valid code
    code.activate!(current_user)
    redirect_back(fallback_location: subscription_path, notice: "Promo code successfully activated!")
  end

  private

  def move_user_to_plan_requested(plan_id)
    if plan_id == 'starter'
      process_plan_change(current_user, plan_id)
    else
      stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id

      # If we're upgrading to premium, we want to check that a payment method
      # is already on file. If it is, we process the plan change. If it's not,
      # we redirect to the payment method page.
      if stripe_customer.sources.total_count > 0
        process_plan_change(current_user, plan_id)
      else
        return :payment_method_needed
      end
    end
  end

  def process_plan_change(user, new_plan_id)
    # General flow we're going to take here:
    # 1. Cancel all existing plans, reversing their benefits
    SubscriptionService.cancel_all_existing_subscriptions(user)

    # 2. Add a new plan, adding its benefits
    SubscriptionService.add_subscription(user, new_plan_id)
  end
end
