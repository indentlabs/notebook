require 'test_helper'

class SubscriptionServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.update_column(:selected_billing_plan_id, 1)

    # A premium plan (id must be in BillingPlan::PREMIUM_IDS for the premium-only logic to apply).
    @plan = BillingPlan.create!(
      id:                 4,
      name:               'Premium',
      stripe_plan_id:     'premium',
      monthly_cents:      500,
      available:          true,
      bonus_bandwidth_kb: 0
    )
  end

  test "add_subscription creates exactly one active subscription" do
    SubscriptionService.add_subscription(@user, 'premium')

    assert_equal 1, @user.subscriptions.active.count
    assert_equal @plan.id, @user.reload.selected_billing_plan_id
  end

  test "add_subscription is an idempotent no-op when already subscribed to the same plan" do
    SubscriptionService.add_subscription(@user, 'premium')

    result = nil
    assert_no_difference -> { @user.subscriptions.active.count } do
      result = SubscriptionService.add_subscription(@user, 'premium')
    end

    assert_equal :already_subscribed, result
    assert_equal 1, @user.subscriptions.active.count
  end

  test "change_plan called repeatedly never leaves more than one active subscription" do
    3.times { SubscriptionService.change_plan(@user, 'premium') }

    assert_equal 1, @user.subscriptions.active.count
  end

  test "an unavailable plan id raises rather than creating a subscription" do
    @plan.update_column(:available, false)

    assert_raises(RuntimeError) do
      SubscriptionService.add_subscription(@user, 'premium')
    end
    assert_equal 0, @user.subscriptions.active.count
  end
end
