class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :billing_plan

  # A subscription is "active" if we're currently inside its [start_date, end_date) window.
  # Cancellation is modeled by setting end_date to (roughly) now, so a cancelled subscription
  # falls out of this scope immediately.
  scope :active, -> {
    where('start_date < ?', Time.now).where('end_date > ?', Time.now)
  }

  # Application-level guard against the double-billing bug: a user should never have more than
  # one active subscription at a time. The pessimistic lock in SubscriptionService is what makes
  # this race-safe; this validation is a second layer that also protects any other creation path.
  validate :no_other_active_subscription, on: :create

  private

  def no_other_active_subscription
    # Only enforce the invariant for subscriptions that are themselves active.
    return if end_date.present? && end_date <= Time.now
    return if start_date.present? && start_date >= Time.now

    conflicting = Subscription.active.where(user_id: user_id)
    conflicting = conflicting.where.not(id: id) if persisted?

    if conflicting.exists?
      errors.add(:base, 'User already has an active subscription')
    end
  end
end
