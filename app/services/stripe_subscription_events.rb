class StripeSubscriptionEvents
  attr_reader :event, :user

  def initialize(event)
    @event = event
    @user  = User.find_by(stripe_customer_id: stripe_customer)
  end

  # Fired when a subscription is cancelled/ends on Stripe. Treat Stripe as the source of truth:
  # if the customer no longer has any active Stripe subscription, make sure they're downgraded
  # locally too. Runs under a lock so it can't race with an in-app plan change.
  def deleted
    return unless user.present?

    user.with_lock do
      SubscriptionService.cancel_all_existing_subscriptions(user) unless active_stripe_subscriptions?
    end
  end

  private

  def stripe_subscription
    event.data.object
  end

  def stripe_customer
    stripe_subscription.customer
  end

  # Is there still at least one non-cancelled subscription on the Stripe customer? In tests we
  # don't talk to Stripe, so assume none remain (the event told us one was deleted).
  def active_stripe_subscriptions?
    return false if Rails.env.test?

    customer      = Stripe::Customer.retrieve(stripe_customer)
    subscriptions = customer.subscriptions&.data || []
    subscriptions.any? { |sub| %w[active trialing past_due].include?(sub.status) }
  end
end
