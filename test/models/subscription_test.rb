require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @plan = BillingPlan.create!(
      id:             4,
      name:           'Premium',
      stripe_plan_id: 'premium',
      monthly_cents:  500,
      available:      true
    )
  end

  test "a user may have one active subscription" do
    subscription = @user.subscriptions.build(
      billing_plan: @plan,
      start_date:   1.day.ago,
      end_date:     1.year.from_now
    )
    assert subscription.valid?
  end

  test "a user cannot have two overlapping active subscriptions" do
    @user.subscriptions.create!(
      billing_plan: @plan,
      start_date:   1.day.ago,
      end_date:     1.year.from_now
    )

    duplicate = @user.subscriptions.build(
      billing_plan: @plan,
      start_date:   1.hour.ago,
      end_date:     1.year.from_now
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:base], 'User already has an active subscription'
  end

  test "a cancelled (past end_date) subscription does not block a new one" do
    @user.subscriptions.create!(
      billing_plan: @plan,
      start_date:   2.years.ago,
      end_date:     1.day.ago
    )

    new_subscription = @user.subscriptions.build(
      billing_plan: @plan,
      start_date:   1.hour.ago,
      end_date:     1.year.from_now
    )

    assert new_subscription.valid?
  end
end
