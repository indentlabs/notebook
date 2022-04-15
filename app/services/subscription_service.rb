class SubscriptionService < Service
  #todo: support multiple simultaneous plans

  def self.add_subscription(user, plan_id)
    related_plan = BillingPlan.find_by(stripe_plan_id: plan_id, available: true)
    raise "Plan #{plan_id} not available for user #{user.id}" if related_plan.nil?

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
          end_date:        DateTime.now.end_of_day + 10.years
        )

        user.notifications.create(
          message_html:     "<div class='yellow-text text-darken-4'>You signed up for Premium!</div><div>Click here to turn on your Premium pages.</div>",
          icon:             'star',
          icon_color:       'text-darken-3 yellow',
          happened_at:      DateTime.current,
          passthrough_link: Rails.application.routes.url_helpers.customization_content_types_path,
          reference_code:   'premium-activation'
        ) if user.reload.on_premium_plan?

        report_subscription_change_to_slack(user, plan_id)

      rescue Stripe::CardError => e
        return :failed_card
      end
    end
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
    user.update(selected_billing_plan_id: 1)
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

    related_plan        = BillingPlan.find_by(stripe_plan_id: plan_id)
    total_subscriptions = 0
    monthly_rev_cents   = 0
    billing_plans_with_prices = BillingPlan.where.not(monthly_cents: 0).pluck(:id, :monthly_cents)
    billing_plans_with_prices.each do |bp_plan_id, monthly_cents|
      users_on_this_plan  = User.where(selected_billing_plan_id: bp_plan_id).count
      total_subscriptions += users_on_this_plan
      monthly_rev_cents   += monthly_cents * users_on_this_plan
    end

    SlackService.post('#subscriptions',
      [
        "Subscription change for #{user.email.split('@').first}@ (##{user.id})",
        "To: *#{related_plan.name}* (#{related_plan.stripe_plan_id}) ($#{related_plan.monthly_cents / 100.0}/month)",
        "#{total_subscriptions} subscriptions total $#{'%.2f' % (monthly_rev_cents / 100)}/mo"
      ].join("\n")
    )
  end

  def self.recalculate_bandwidth_for(user)
    base_bandwidth = User.new.upload_bandwidth_kb           #     50_000
    premium_bonus  = BillingPlan.find(4).bonus_bandwidth_kb #  9_950_000
    premium_total  = base_bandwidth + premium_bonus         # 10_000_000
    referral_bonus = 100_000 # per referral

    max_bandwidth = case user.selected_billing_plan_id
      when nil, 1
        base_bandwidth
      when 2 # free-for-lifers
        250_000
      when 4, 5, 6 # premium
        premium_total
      else
        raise "User with funky billing plan id: U=#{user.id} BP=#{user.selected_billing_plan_id}"
    end

    referral_bonus = user.referrals.count * referral_bonus
    used_bandwidth = user.image_uploads.sum(:src_file_size) / 1000

    remaining_bandwidth = max_bandwidth + referral_bonus - used_bandwidth

    return remaining_bandwidth
  end

end
