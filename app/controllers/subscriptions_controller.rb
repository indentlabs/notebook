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
    possible_plan_ids = BillingPlan.where(available: true).map(&:stripe_plan_id)

    raise "Invalid billing plan ID: #{new_plan_id}" unless possible_plan_ids.include? new_plan_id

    # If the user is changing to Starter, go ahead and cancel any active subscriptions and do it
    if new_plan_id == 'starter'
      current_user.active_subscriptions.each do |subscription|
        subscription.update(end_date: Time.now)
      end

      if current_user.selected_billing_plan_id.nil?
        old_billing_plan = BillingPlan.new(name: 'No billing plan', monthly_cents: 0)
      else
        old_billing_plan = BillingPlan.find(current_user.selected_billing_plan_id)
      end
      new_billing_plan = BillingPlan.find_by(stripe_plan_id: new_plan_id, available: true)
      current_user.selected_billing_plan_id = new_billing_plan.id

      # Remove any bonus bandwidth our old plan granted
      current_user.upload_bandwidth_kb -= old_billing_plan.bonus_bandwidth_kb

      current_user.save

      Subscription.create(
        user: current_user,
        billing_plan: new_billing_plan,
        start_date: Time.now,
        end_date: Time.now.end_of_day + 5.years
      )

      unless Rails.env.test?
        stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
        stripe_subscription = stripe_customer.subscriptions.data[0]
        stripe_subscription.save
      end

      report_subscription_change_to_slack current_user, old_billing_plan, new_billing_plan

      flash[:notice] = "You have been successfully downgraded to Starter." #todo proration/credit
      return redirect_to subscription_path
    end

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
        stripe_subscription.save unless Rails.env.test?
      rescue Stripe::CardError => e
        flash[:alert] = "We couldn't upgrade you to Premium because #{e.message.downcase} Please double check that your information is correct."
        return redirect_to :back
      end

      # If this is the first time this user is subscribing to Premium, gift them (and their referrer, if applicable) feature votes and space
      existing_premium_subscriptions = current_user.subscriptions.where(billing_plan_id: BillingPlan::PREMIUM_IDS)
      unless existing_premium_subscriptions.any?
        referring_user = current_user.referrer || current_user

        # First-time premium!
        # +100 MB
        current_user.update upload_bandwidth_kb: current_user.upload_bandwidth_kb + 100_000
        current_user.reload

        # +1 vote
        current_user.votes.create
        # +1 vote if referred
        current_user.votes.create if referring_user.present?

        # +1 raffle entry
        current_user.raffle_entries.create
        # +1 raffle entry if referred
        current_user.raffle_entries.create if referring_user.present?

        if referring_user
          # +100MB
          referring_user.update upload_bandwidth_kb: referring_user.upload_bandwidth_kb + 100_000

          # +2 votes
          referring_user.votes.create
          referring_user.votes.create

          # +2 raffle entries
          referring_user.raffle_entries.create
          referring_user.raffle_entries.create
        end
      end

      if current_user.selected_billing_plan_id.nil?
        old_billing_plan = BillingPlan.new(name: 'No billing plan', monthly_cents: 0)
      else
        old_billing_plan = BillingPlan.find(current_user.selected_billing_plan_id)
      end
      new_billing_plan = BillingPlan.find_by(stripe_plan_id: new_plan_id, available: true)
      current_user.selected_billing_plan_id = new_billing_plan.id

      # Add any bonus bandwidth our new plan grants, unless we're moving from Premium to Premium
      premium_ids = [3, 4, 5, 6]
      if !premium_ids.include?(current_user.selected_billing_plan_id) && premium_ids.include?(new_plan_id)
        current_user.upload_bandwidth_kb += new_billing_plan.bonus_bandwidth_kb
      end

      current_user.save

      Subscription.create(
        user: current_user,
        billing_plan: new_billing_plan,
        start_date: Time.now,
        end_date: Time.now.end_of_day + 5.years
      )

      report_subscription_change_to_slack current_user, old_billing_plan, new_billing_plan

      flash[:notice] = "You have been successfully upgraded to #{new_billing_plan.name}!"
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
      if current_user.selected_billing_plan_id.nil?
        old_billing_plan = BillingPlan.new(name: 'No billing plan', monthly_cents: 0)
      else
        old_billing_plan = BillingPlan.find(current_user.selected_billing_plan_id)
      end
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
      current_user.active_subscriptions.each do |subscription|
        subscription.update(end_date: Time.now)
      end

      # If this is the first time this user is subscribing to Premium, gift them (and their referrer, if applicable) feature votes and space
      existing_premium_subscriptions = current_user.subscriptions.where(billing_plan_id: BillingPlan::PREMIUM_IDS)
      unless existing_premium_subscriptions.any?
        referring_user = current_user.referrer || current_user

        # First-time premium!
        # +100 MB
        current_user.update upload_bandwidth_kb: current_user.upload_bandwidth_kb + 100_000
        current_user.reload

        # +1 vote
        current_user.votes.create
        # +1 vote if referred
        current_user.votes.create if referring_user.present?

        # +1 raffle entry
        current_user.raffle_entries.create
        # +1 raffle entry if referred
        current_user.raffle_entries.create if referring_user.present?

        if referring_user
          # +100MB
          referring_user.update upload_bandwidth_kb: referring_user.upload_bandwidth_kb + 100_000

          # +2 votes
          referring_user.votes.create
          referring_user.votes.create

          # +2 raffle entries
          referring_user.raffle_entries.create
          referring_user.raffle_entries.create
        end
      end

      # And create a subscription for them for the current plan
      Subscription.create(
        user: current_user,
        billing_plan: new_billing_plan,
        start_date: Time.now,
        end_date: Time.now.end_of_day + 31.days
      )

      report_subscription_change_to_slack current_user, old_billing_plan, new_billing_plan

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

  def report_subscription_change_to_slack user, from, to
    return unless Rails.env == 'production'
    slack_hook = ENV['SLACK_HOOK']
    return unless slack_hook

    notifier = Slack::Notifier.new slack_hook,
      channel: '#subscriptions',
      username: 'tristan'

    if from.nil? || to.nil?
      delta = ":tada: LOL :tada:"
    elsif from.monthly_cents < to.monthly_cents
      delta = ":tada: *UPGRADE* :tada:"
    elsif from.monthly_cents == to.monthly_cents
      delta = ":tada: ... sidegrade ... :tada:"
    else
      delta = ":wave: Downgrade"
    end

    total_subscriptions = 0
    monthly_rev_cents = 0
    billing_plans_with_prices = BillingPlan.where.not(monthly_cents: 0).pluck(:id, :monthly_cents)
    billing_plans_with_prices.each do |plan_id, monthly_cents|
      users_on_this_plan  = User.where(selected_billing_plan_id: plan_id).count
      total_subscriptions += users_on_this_plan
      monthly_rev_cents   += monthly_cents * users_on_this_plan
    end

    notifier.ping [
      "#{delta} for #{user.email.split('@').first}@ (##{user.id})",
      "From: *#{from.name}* ($#{from.monthly_cents / 100.0}/month)",
      "To: *#{to.name}* (#{to.stripe_plan_id}) ($#{to.monthly_cents / 100.0}/month)",
      "#{total_subscriptions} subscriptions total $#{'%.2f' % (monthly_rev_cents / 100)}/mo"
    ].join("\n")

  end
end
