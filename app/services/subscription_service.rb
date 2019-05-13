class SubscriptionService < Service
  #todo: support multiple simultaneous plans

  def self.add_subscription(user, plan_id)
    related_plan = BillingPlan.find_by(stripe_plan_id: plan_id, available: true)
    raise "Plan #{plan_id} not available for user #{user.id}" if related_plan.nil?

    # Add any bonus bandwidth granted by the plan
    user.update(
      upload_bandwidth_kb: user.upload_bandwidth_kb + related_plan.bonus_bandwidth_kb
    )

    # Add any one-time referral bonuses
    add_any_referral_bonuses(user, plan_id)

    # We intentionally skip callbacks on this to ensure the billing plan changes even on invalid users
    user.update_column(:selected_billing_plan_id, related_plan.id)

    user.subscriptions.create(
      billing_plan:    related_plan,
      start_date:      DateTime.now,
      end_date:        DateTime.now.end_of_day + 5.years
    )

    # Sync with Stripe (todo pipe into StripeService)
    unless Rails.env.test?
      stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.data[0]

      if stripe_subscription.nil?
        # Create a new subscription on Stripe
        Stripe::Subscription.create(customer: user.stripe_customer_id, plan: plan_id)
        stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
        stripe_subscription = stripe_customer.subscriptions.data[0]
      else
        # Edit an existing Stripe subscription
        stripe_subscription.plan = plan_id
      end

      # Save the change
      begin
        stripe_subscription.save unless Rails.env.test?
      rescue Stripe::CardError => e
        flash[:alert] = "We couldn't upgrade you to Premium because #{e.message.downcase} Please double check that your information is correct."
        return :failed_card
      end
    end

    report_subscription_change_to_slack(user, plan_id)
  end

  def self.remove_subscription(user, subscription)
    related_plan = subscription.billing_plan

    # Remove any bonus bandwidth granted by the plan
    user.update(
      upload_bandwidth_kb: user.upload_bandwidth_kb - related_plan.bonus_bandwidth_kb
    )
    subscription.update(end_date: DateTime.now)
  end

  def self.cancel_all_existing_subscriptions(user)
    user.active_subscriptions.each do |subscription|
      remove_subscription(user, subscription)
    end
  end

  def self.add_any_referral_bonuses(user, plan_id)
    # This only applies if we're upgrading to premium, obviously
    related_billing_plan = BillingPlan.find_by(stripe_plan_id: plan_id)
    return unless BillingPlan::PREMIUM_IDS.include?(related_billing_plan.id)

    # If this is the first time this user is subscribing to Premium, gift them (and their referrer, if applicable) extra space
    existing_premium_subscriptions = user.subscriptions.where(billing_plan_id: BillingPlan::PREMIUM_IDS)
    return if existing_premium_subscriptions.any?

    # 100MB bonus to you
    user.update(
      upload_bandwidth_kb: user.upload_bandwidth_kb + 100_000
    )

    # 100MB bonus to your referrer
    referring_user = user.referrer
    if referring_user
      referring_user.update(
        upload_bandwidth_kb: referring_user.upload_bandwidth_kb + 100_000
      )
    end
  end

  def self.available_plans
    BillingPlan.where(available: true)
  end

  def self.dummy_starter_plan
    BillingPlan.new(name: 'No billing plan', monthly_cents: 0)
  end

  def self.report_subscription_change_to_slack(user, plan_id)
    return unless Rails.env == 'production'
    slack_hook = ENV['SLACK_HOOK']
    return unless slack_hook

    related_plan = BillingPlan.find_by(stripe_plan_id: plan_id)

    notifier = Slack::Notifier.new slack_hook,
      channel: '#subscriptions',
      username: 'tristan'

    total_subscriptions = 0
    monthly_rev_cents = 0
    billing_plans_with_prices = BillingPlan.where.not(monthly_cents: 0).pluck(:id, :monthly_cents)
    billing_plans_with_prices.each do |plan_id, monthly_cents|
      users_on_this_plan  = User.where(selected_billing_plan_id: plan_id).count
      total_subscriptions += users_on_this_plan
      monthly_rev_cents   += monthly_cents * users_on_this_plan
    end

    notifier.ping [
      "Subscription change for #{user.email.split('@').first}@ (##{user.id})",
      "To: *#{related_plan.name}* (#{related_plan.stripe_plan_id}) ($#{related_plan.monthly_cents / 100.0}/month)",
      "#{total_subscriptions} subscriptions total $#{'%.2f' % (monthly_rev_cents / 100)}/mo"
    ].join("\n")
  end
end
