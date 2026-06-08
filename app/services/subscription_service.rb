class SubscriptionService < Service
  #todo: support multiple simultaneous plans

  # Single entry point for changing a user's plan.
  #
  # Everything runs under a pessimistic per-user lock so two concurrent requests (the classic
  # "double-click while the site is slow" scenario) can't both create a subscription. Without
  # this lock both requests would see no existing Stripe subscription and each would call
  # Stripe::Subscription.create, double-billing the customer.
  def self.change_plan(user, new_plan_id)
    user.with_lock do
      # 1. Cancel all existing plans, reversing their benefits
      cancel_all_existing_subscriptions(user)

      # 2. Add the new plan, adding its benefits
      add_subscription(user, new_plan_id)
    end
  end

  def self.add_subscription(user, plan_id)
    related_plan = BillingPlan.find_by(stripe_plan_id: plan_id, available: true)
    raise "Plan #{plan_id} not available for user #{user.id}" if related_plan.nil?

    result = nil

    # with_lock opens a transaction and SELECT ... FOR UPDATEs the user row, serializing
    # concurrent plan changes for this user and rolling back cleanly if anything below raises.
    user.with_lock do
      # Idempotency guard: if the user is already actively subscribed to this exact plan,
      # there is nothing to do. This makes retries / double-submits a safe no-op.
      if user.subscriptions.active.exists?(billing_plan_id: related_plan.id)
        result = :already_subscribed
        next
      end

      # Sync with Stripe (todo pipe into StripeService). Returns the Stripe subscription id so we
      # can store it locally for reconciliation. Skipped entirely in the test environment.
      stripe_subscription_id = sync_stripe_subscription(user, plan_id)

      # Add any bonus bandwidth granted by the plan
      user.update(
        upload_bandwidth_kb: user.upload_bandwidth_kb + related_plan.bonus_bandwidth_kb
      )

      # Add any one-time referral bonuses
      add_any_referral_bonuses(user, plan_id)

      # We intentionally skip callbacks on this to ensure the billing plan changes even on invalid users
      user.update_column(:selected_billing_plan_id, related_plan.id)

      user.subscriptions.create!(
        billing_plan:           related_plan,
        stripe_subscription_id: stripe_subscription_id,
        start_date:             DateTime.now,
        end_date:               DateTime.now.end_of_day + 10.years
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
    end

    result
  rescue Stripe::CardError => e
    :failed_card
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
    # A concurrent request beat us to creating this subscription (the unique invariant kicked in).
    # Treat it as an idempotent no-op rather than surfacing an error to the user.
    Rails.logger.warn("[SubscriptionService] Skipped duplicate subscription for user #{user.id}: #{e.message}")
    :already_subscribed
  end

  # Pushes the desired plan to Stripe and returns the Stripe subscription id (or nil in test).
  #
  # All write calls carry an idempotency_key so that if the same logical change is retried within
  # Stripe's dedup window, Stripe collapses it into a single operation instead of creating a
  # second subscription / charge.
  def self.sync_stripe_subscription(user, plan_id)
    return nil if Rails.env.test?

    stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)

    # Use safe navigation to handle customers without subscriptions
    subscriptions = stripe_customer.subscriptions&.data || []
    stripe_subscription = subscriptions.first

    if stripe_subscription.nil?
      # Get the customer's default payment method
      payment_methods = Stripe::PaymentMethod.list({
        customer: user.stripe_customer_id,
        type: 'card'
      })

      default_payment_method = payment_methods.data.first&.id

      # Create a new subscription on Stripe with the default payment method
      subscription_params = {
        customer: user.stripe_customer_id,
        items: [{ price: plan_id }]
      }

      # Add default payment method if available
      if default_payment_method
        subscription_params[:default_payment_method] = default_payment_method
      end

      stripe_subscription = Stripe::Subscription.create(
        subscription_params,
        idempotency_key: stripe_idempotency_key('create', user, plan_id)
      )
    else
      # Edit an existing Stripe subscription by modifying its items
      Stripe::Subscription.modify(
        stripe_subscription.id,
        {
          items: [{
            id: stripe_subscription.items.data[0].id,
            price: plan_id
          }]
        },
        { idempotency_key: stripe_idempotency_key('modify', user, plan_id) }
      )
      # Retrieve the updated subscription
      stripe_subscription = Stripe::Subscription.retrieve(stripe_subscription.id)
    end

    stripe_subscription&.id
  end

  # A stable key shared by retries of the same logical operation on the same day, so that a
  # double-submit dedupes at Stripe while a genuine re-subscription on another day does not.
  def self.stripe_idempotency_key(action, user, plan_id)
    "sub-#{action}-#{user.id}-#{plan_id}-#{Date.current.iso8601}"
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
