require 'test_helper'
require 'webmock/minitest'
require 'minitest/mock'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  STRIPE_BASE = 'https://api.stripe.com/v1'.freeze

  def setup
    @starter_plan = BillingPlan.find_or_create_by!(stripe_plan_id: 'starter') do |plan|
      plan.name = 'Starter'
      plan.monthly_cents = 0
      plan.available = true
      plan.bonus_bandwidth_kb = 0
    end
    @premium_plan = BillingPlan.find_or_create_by!(stripe_plan_id: 'premium') do |plan|
      plan.name = 'Premium'
      plan.monthly_cents = 900
      plan.available = true
      plan.bonus_bandwidth_kb = 9_950_000
    end
    @annual_plan = BillingPlan.find_or_create_by!(stripe_plan_id: 'premium-annual') do |plan|
      plan.name = 'Premium (annual)'
      plan.monthly_cents = 700
      plan.available = true
      plan.bonus_bandwidth_kb = 9_950_000
    end

    @user = users(:one)
    @user.update!(stripe_customer_id: 'cus_test')
    sign_in @user

    stub_request(:get, "#{STRIPE_BASE}/customers/cus_test")
      .to_return(status: 200, body: { id: 'cus_test' }.to_json)
    stub_request(:get, "#{STRIPE_BASE}/customers/cus_test/payment_methods")
      .with(query: { type: 'card' })
      .to_return(status: 200, body: { object: 'list', data: [{ id: 'pm_123' }] }.to_json)
  end

  test "a declined card leaves the user's existing plan, bandwidth and subscriptions untouched" do
    @user.update!(selected_billing_plan_id: @premium_plan.id, upload_bandwidth_kb: 10_000_000)
    @user.subscriptions.create!(
      billing_plan: @premium_plan,
      start_date:   1.day.ago,
      end_date:     10.years.from_now
    )

    declined = lambda do |*|
      raise Stripe::CardError.new('Your card was declined.', 'number')
    end

    SubscriptionService.stub(:add_subscription, declined) do
      post change_subscription_path('premium-annual')
    end

    @user.reload
    assert_equal @premium_plan.id, @user.selected_billing_plan_id,
      'the declined card should not have downgraded the user'
    assert_equal 10_000_000, @user.upload_bandwidth_kb,
      'the declined card should not have stripped the premium bandwidth bonus'
    assert_equal [@premium_plan.id], @user.active_subscriptions.map(&:billing_plan_id),
      'the local premium subscription should still be active'
    assert_redirected_to payment_info_path(plan: 'premium-annual')
  end

  test "plan changes are accepted over POST" do
    @user.update!(selected_billing_plan_id: @premium_plan.id)

    post change_subscription_path('starter')

    assert_redirected_to subscription_path
    assert_equal @starter_plan.id, @user.reload.selected_billing_plan_id
  end
end
