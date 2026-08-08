require 'test_helper'
require 'webmock/minitest'

class SubscriptionServiceTest < ActiveSupport::TestCase
  STRIPE_BASE = 'https://api.stripe.com/v1'.freeze

  def setup
    @user = users(:one)
    @user.update(stripe_customer_id: 'cus_test')
  end

  def stripe_subscription_json(id, price_id, status: 'active', cancel_at_period_end: false, created: 1_600_000_000)
    {
      id: id,
      object: 'subscription',
      customer: 'cus_test',
      status: status,
      created: created,
      cancel_at_period_end: cancel_at_period_end,
      items: {
        object: 'list',
        data: [{
          id: "si_#{id}",
          object: 'subscription_item',
          price: { id: price_id, object: 'price' }
        }]
      }
    }
  end

  def stub_subscription_list(subscriptions)
    stub_request(:get, "#{STRIPE_BASE}/subscriptions")
      .with(query: { customer: 'cus_test', status: 'all', limit: '100' })
      .to_return(
        status: 200,
        body: { object: 'list', url: '/v1/subscriptions', has_more: false, data: subscriptions }.to_json
      )
  end

  def stub_no_payment_methods
    stub_request(:get, "#{STRIPE_BASE}/payment_methods")
      .with(query: { customer: 'cus_test', type: 'card' })
      .to_return(status: 200, body: { object: 'list', data: [] }.to_json)
  end

  test "billable_stripe_subscriptions filters out canceled and expired subscriptions" do
    stub_subscription_list([
      stripe_subscription_json('sub_active',   'premium', status: 'active'),
      stripe_subscription_json('sub_canceled', 'starter', status: 'canceled'),
      stripe_subscription_json('sub_expired',  'starter', status: 'incomplete_expired'),
      stripe_subscription_json('sub_pastdue',  'starter', status: 'past_due')
    ])

    subscriptions = SubscriptionService.billable_stripe_subscriptions('cus_test')
    assert_equal %w[sub_active sub_pastdue], subscriptions.map(&:id).sort
  end

  test "billable_stripe_subscriptions is empty for users without a Stripe customer" do
    assert_equal [], SubscriptionService.billable_stripe_subscriptions(nil)
    assert_equal [], SubscriptionService.billable_stripe_subscriptions('')
  end

  test "sync cancels parallel subscriptions and keeps the one on the requested plan" do
    stub_subscription_list([
      stripe_subscription_json('sub_starter_1', 'starter'),
      stripe_subscription_json('sub_premium',   'premium'),
      stripe_subscription_json('sub_starter_2', 'starter')
    ])
    cancel_1 = stub_request(:delete, "#{STRIPE_BASE}/subscriptions/sub_starter_1")
      .with(query: { prorate: 'true' })
      .to_return(status: 200, body: { id: 'sub_starter_1' }.to_json)
    cancel_2 = stub_request(:delete, "#{STRIPE_BASE}/subscriptions/sub_starter_2")
      .with(query: { prorate: 'true' })
      .to_return(status: 200, body: { id: 'sub_starter_2' }.to_json)

    kept = SubscriptionService.sync_stripe_subscriptions_to_plan(@user, 'premium')

    assert_equal 'sub_premium', kept.id
    assert_requested cancel_1
    assert_requested cancel_2
    assert_not_requested :post, "#{STRIPE_BASE}/subscriptions"
    assert_not_requested :post, "#{STRIPE_BASE}/subscriptions/sub_premium"
  end

  test "sync modifies the existing subscription instead of creating a second one" do
    stub_subscription_list([
      stripe_subscription_json('sub_starter', 'starter')
    ])
    modify = stub_request(:post, "#{STRIPE_BASE}/subscriptions/sub_starter")
      .with(body: { items: [{ id: 'si_sub_starter', price: 'premium' }] })
      .to_return(status: 200, body: stripe_subscription_json('sub_starter', 'premium').to_json)
    stub_request(:get, "#{STRIPE_BASE}/subscriptions/sub_starter")
      .to_return(status: 200, body: stripe_subscription_json('sub_starter', 'premium').to_json)

    SubscriptionService.sync_stripe_subscriptions_to_plan(@user, 'premium')

    assert_requested modify
    assert_not_requested :post, "#{STRIPE_BASE}/subscriptions"
  end

  test "sync creates a single subscription when the customer has none" do
    stub_subscription_list([])
    stub_no_payment_methods
    create = stub_request(:post, "#{STRIPE_BASE}/subscriptions")
      .with(body: { customer: 'cus_test', items: [{ price: 'premium' }], payment_behavior: 'error_if_incomplete' })
      .to_return(status: 200, body: stripe_subscription_json('sub_new', 'premium').to_json)

    SubscriptionService.sync_stripe_subscriptions_to_plan(@user, 'premium')

    assert_requested create
  end

  test "sync is a no-op when the customer is already on the requested plan" do
    stub_subscription_list([
      stripe_subscription_json('sub_premium', 'premium')
    ])

    kept = SubscriptionService.sync_stripe_subscriptions_to_plan(@user, 'premium')

    assert_equal 'sub_premium', kept.id
    assert_not_requested :post, "#{STRIPE_BASE}/subscriptions"
    assert_not_requested :post, "#{STRIPE_BASE}/subscriptions/sub_premium"
    assert_not_requested :delete, %r{#{STRIPE_BASE}/subscriptions/sub_premium}
  end

  test "sync un-cancels a subscription scheduled for cancellation when re-choosing the same plan" do
    stub_subscription_list([
      stripe_subscription_json('sub_premium', 'premium', cancel_at_period_end: true)
    ])
    modify = stub_request(:post, "#{STRIPE_BASE}/subscriptions/sub_premium")
      .with(body: { cancel_at_period_end: 'false' })
      .to_return(status: 200, body: stripe_subscription_json('sub_premium', 'premium').to_json)

    SubscriptionService.sync_stripe_subscriptions_to_plan(@user, 'premium')

    assert_requested modify
  end

  test "sync keeps the active subscription over an incomplete duplicate on the same plan" do
    stub_subscription_list([
      stripe_subscription_json('sub_incomplete', 'premium', status: 'incomplete', created: 1_700_000_000),
      stripe_subscription_json('sub_active',     'premium', status: 'active',     created: 1_600_000_000)
    ])
    cancel = stub_request(:delete, "#{STRIPE_BASE}/subscriptions/sub_incomplete")
      .with(query: { prorate: 'true' })
      .to_return(status: 200, body: { id: 'sub_incomplete' }.to_json)

    kept = SubscriptionService.sync_stripe_subscriptions_to_plan(@user, 'premium')

    assert_equal 'sub_active', kept.id
    assert_requested cancel
    assert_not_requested :delete, %r{#{STRIPE_BASE}/subscriptions/sub_active}
  end

  test "subscription_period_end falls back to item-level period ends" do
    subscription = Stripe::Subscription.construct_from(
      id: 'sub_x',
      items: { object: 'list', data: [{ id: 'si_x', current_period_end: 1_700_000_000 }] }
    )
    assert_equal 1_700_000_000, SubscriptionService.subscription_period_end(subscription)

    subscription_with_top_level = Stripe::Subscription.construct_from(
      id: 'sub_y',
      current_period_end: 1_650_000_000,
      items: { object: 'list', data: [] }
    )
    assert_equal 1_650_000_000, SubscriptionService.subscription_period_end(subscription_with_top_level)
  end
end
