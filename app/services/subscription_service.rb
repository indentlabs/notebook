class SubscriptionService < Service
  STARTER_PLAN_IDS = [1]
  FREE_FOR_LIFE_PLAN_IDS = [2]
  PAID_PREMIUM_PLAN_IDS = [3, 4, 5, 6]

  SUBSCRIPTION_LENGTH = 5.years #todo refactor this out

  def self.transition_plan user:, old_plan:, new_plan:, stripe_object: nil
    # Fetch the user's current Stripe information
    stripe_object ||= SubscriptionService.stripe_customer_object_for(current_user)
    stripe_subscription = stripe_object.subscriptions.data[0]

    # End all active subscriptions
    SubscriptionService.end_all_active_subscriptions_for(user)

    # Move the user over to their new plan on Stripe
    stripe_subscription.plan = new_plan.id
    begin
      stripe_subscription.save
    rescue Stripe::CardError => e
      flash[:alert] = "We couldn't upgrade you to Premium because #{e.message.downcase} Please double check that your information is correct."
      return false
    end

    # Move user over to their new billing plan
    user.selected_billing_plan_id = new_plan.id

    # Remove any added space from the old plan
    user.upload_bandwidth_kb -= old_plan.bonus_bandwidth_kb

    # Add any added space from the new plan
    user.upload_bandwidth_kb += new_plan.bonus_bandwidth_kb

    # Add any first-time-premium bonuses
    if self.first_time_premium?(user)
      add_first_time_premium_benefits_to(user)
      add_referral_benefits_to(
        referree: user
        referrer: user.referrer || user # if a user wasn't referred by anyone, we treat them as referring themselves <3
      )
    end

    # Save all changes to the user!
    user.save!

    # Create the new Subscription object
    Subscription.create(
      user:         user,
      billing_plan: new_plan,
      start_date:   DateTime.current,
      end_date:     DateTime.current.end_of_day + self.SUBSCRIPTION_LENGTH
    )

    # Let Slack know about the changes
    SubscriptionService.report_subscription_change_to_slack user, old_plan, new_plan

    # Success!
    true

  # rescue
  #   false
  end

  def self.stripe_customer_object_for user
    Stripe::Customer.retrieve user.stripe_customer_id
  end

  def self.has_card_on_file_for? stripe_object
    stripe_object.sources.total_count > 0
  end

  def self.first_time_premium? user
    user.subscriptions.where(billing_plan_id: PAID_PREMIUM_PLAN_IDS).empty?
  end

  def self.available_plan? id:
    possible_plan_ids = BillingPlan.where(available: true).pluck(:stripe_plan_id)
    possible_plan_ids.include?(id)
  end

  def self.current_billing_plan_for user
    if user.selected_billing_plan_id.nil?
      BillingPlan.new(name: 'No billing plan', monthly_cents: 0)
    else
      BillingPlan.find(user.selected_billing_plan_id)
    end
  end

  def self.end_all_active_subscriptions_for user
    user.active_subscriptions.each do |subscription|
      subscription.update(end_date: DateTime.current)
    end
  end

  def self.add_first_time_premium_benefits_to user
    # +100 MB
    user.update(upload_bandwidth_kb: user.upload_bandwidth_kb + 100_000)

    # +1 vote
    user.votes.create
  end

  def self.add_referral_benefits_to referree:, referrer:
    # +1 vote for referred user
    referree.votes.create

    # +2 votes for referring user
    referrer.votes.create
    referrer.votes.create

    # +100MB for referrer
    referrer.update(upload_bandwidth_kb: referrer.upload_bandwidth_kb + 100_000)
  end

  def self.report_subscription_change_to_slack user, from, to
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

    active_subscriptions = Subscription.where('start_date < ?', Time.now).where('end_date > ?', Time.now)
    total_subs_monthly = active_subscriptions.map(&:billing_plan).sum(&:monthly_cents).to_f / 100.0

    notifier.ping [
      "#{delta} for #{user.email.split('@').first}@ (##{user.id})",
      "From: *#{from.name}* ($#{from.monthly_cents / 100.0}/month)",
      "To: *#{to.name}* (#{to.stripe_plan_id}) ($#{to.monthly_cents / 100.0}/month)",
      "#{active_subscriptions.count} subscriptions total $#{'%.2f' % total_subs_monthly}/mo"
    ].join("\n")
  end

end
