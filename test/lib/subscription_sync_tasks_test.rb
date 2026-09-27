require 'test_helper'
require 'webmock/minitest'
require 'rake'

class SubscriptionSyncTasksTest < ActiveSupport::TestCase
  STRIPE_BASE = 'https://api.stripe.com/v1'.freeze

  def self.load_tasks_once
    return if Rake::Task.task_defined?('data_integrity:subscription_synced_with_stripe')
    Rails.application.load_tasks
  end

  def setup
    self.class.load_tasks_once
    Rake::Task['data_integrity:subscription_synced_with_stripe'].reenable
    Rake::Task['incident:restore_premium_from_stripe'].reenable

    @starter = create_plan(1, 'starter', 0)
    create_plan(2, 'free-for-life', 0)
    create_plan(3, 'early-adopters', 0)
    create_plan(5, 'premium-trio', 9_950_000)
    @premium = create_plan(4, 'premium', 9_950_000)
    @annual  = create_plan(6, 'premium-annual', 9_950_000)

    User.update_all(selected_billing_plan_id: nil)
    @user = users(:one)
    @user.update_columns(stripe_customer_id: 'cus_one', selected_billing_plan_id: @premium.id, upload_bandwidth_kb: 10_000_000)
    @user.subscriptions.create!(billing_plan: @premium, start_date: 1.year.ago, end_date: 1.year.ago.end_of_day + 10.years)

    stub_request(:get, "#{STRIPE_BASE}/account").to_return(status: 200, body: { id: 'acct_test', object: 'account' }.to_json)
    @env_backup = ENV.to_h.slice('APPLY', 'REPORT', 'LIMIT')
  end

  def teardown
    %w[APPLY REPORT LIMIT].each { |key| ENV.delete(key) }
    @env_backup.each { |key, value| ENV[key] = value }
  end

  def create_plan(id, stripe_plan_id, bonus)
    BillingPlan.find_by(id: id) || BillingPlan.create!(
      id: id, name: stripe_plan_id, stripe_plan_id: stripe_plan_id, monthly_cents: 0, available: true, bonus_bandwidth_kb: bonus
    )
  end

  def subscription_json(price_id, status: 'active')
    {
      id: "sub_#{price_id}_#{status}", object: 'subscription', status: status, created: 1_600_000_000,
      items: { object: 'list', data: [{ id: 'si_1', object: 'subscription_item', price: { id: price_id, object: 'price' } }] }
    }
  end

  def stub_subscriptions(customer_id, subscriptions)
    stub_request(:get, "#{STRIPE_BASE}/subscriptions")
      .with(query: { customer: customer_id, status: 'all', limit: '100' })
      .to_return(status: 200, body: { object: 'list', url: '/v1/subscriptions', has_more: false, data: subscriptions }.to_json)
  end

  def run_task(name)
    capture_io { Rake::Task[name].invoke }
  end

  # data_integrity:subscription_synced_with_stripe

  test "sync keeps a user whose Stripe subscription matches their plan" do
    stub_subscriptions('cus_one', [subscription_json('premium')])
    ENV['APPLY'] = '1'
    run_task('data_integrity:subscription_synced_with_stripe')
    assert_equal @premium.id, @user.reload.selected_billing_plan_id
  end

  test "sync finds the matching plan on a subscription other than the first" do
    stub_subscriptions('cus_one', [subscription_json('starter'), subscription_json('premium')])
    ENV['APPLY'] = '1'
    run_task('data_integrity:subscription_synced_with_stripe')
    assert_equal @premium.id, @user.reload.selected_billing_plan_id
  end

  test "sync only reports mismatches unless APPLY=1" do
    stub_subscriptions('cus_one', [])
    run_task('data_integrity:subscription_synced_with_stripe')
    assert_equal @premium.id, @user.reload.selected_billing_plan_id
  end

  test "sync downgrades a genuine mismatch with APPLY=1" do
    stub_subscriptions('cus_one', [])
    ENV['APPLY'] = '1'
    run_task('data_integrity:subscription_synced_with_stripe')
    assert_equal @starter.id, @user.reload.selected_billing_plan_id
  end

  test "sync never downgrades on a Stripe API error" do
    stub_request(:get, "#{STRIPE_BASE}/subscriptions").with(query: hash_including(customer: 'cus_one')).to_return(status: 500, body: '{}')
    ENV['APPLY'] = '1'
    assert_raises(SystemExit) { run_task('data_integrity:subscription_synced_with_stripe') }
    assert_equal @premium.id, @user.reload.selected_billing_plan_id
  end

  test "sync aborts before downgrading anyone when mismatches exceed the safety limit" do
    stub_subscriptions('cus_one', [])
    others = 11.times.map do |i|
      user = User.create!(email: "sync-#{i}@example.com", password: 'password', stripe_customer_id: "cus_sync_#{i}")
      user.update_column(:selected_billing_plan_id, @annual.id)
      stub_subscriptions("cus_sync_#{i}", [])
      user
    end

    ENV['APPLY'] = '1'
    assert_raises(SystemExit) { run_task('data_integrity:subscription_synced_with_stripe') }
    assert_equal @premium.id, @user.reload.selected_billing_plan_id
    others.each { |user| assert_equal @annual.id, user.reload.selected_billing_plan_id }
  end

  # incident:restore_premium_from_stripe

  def stripe_subscription(customer, price_id, status: 'active')
    subscription_json(price_id, status: status).merge(id: "sub_#{customer}_#{price_id}", customer: customer)
  end

  # Stubs the per-price, per-status Stripe listings the restore task pages through.
  # Unfiltered listings aren't stubbed, so WebMock fails any test that makes one.
  def stub_stripe_listing(subscriptions)
    %w[early-adopters premium premium-trio premium-annual].each do |price|
      SubscriptionService::BILLABLE_STRIPE_STATUSES.each do |status|
        data = subscriptions.select do |s|
          s[:status] == status && s[:items][:data].any? { |item| item[:price][:id] == price }
        end
        stub_request(:get, "#{STRIPE_BASE}/subscriptions")
          .with(query: { price: price, status: status, limit: '100' })
          .to_return(status: 200, body: { object: 'list', url: '/v1/subscriptions', has_more: false, data: data }.to_json)
      end
    end
  end

  def downgrade!(user)
    SubscriptionService.cancel_all_existing_subscriptions(user)
    user.reload
  end

  def run_restore
    ENV['REPORT'] = File.join(Dir.tmpdir, "restore_test_#{SecureRandom.hex(4)}.csv")
    run_task('incident:restore_premium_from_stripe')
    CSV.read(ENV['REPORT'], headers: true)
  end

  def outcome_for(rows, user)
    rows.find { |row| row['user_id'] == user.id.to_s }&.fetch('outcome')
  end

  test "restore dry run changes nothing and reports the user as restorable" do
    downgrade!(@user)
    stub_stripe_listing([stripe_subscription('cus_one', 'premium')])
    rows = run_restore

    assert_equal @starter.id, @user.reload.selected_billing_plan_id
    assert_equal 'would_restore', outcome_for(rows, @user)
  end

  test "restore with APPLY=1 puts the user back on the plan Stripe bills for" do
    bandwidth_before = @user.upload_bandwidth_kb
    downgrade!(@user)
    stub_stripe_listing([stripe_subscription('cus_one', 'premium-annual'), stripe_subscription('cus_one', 'starter')])

    ENV['APPLY'] = '1'
    rows = run_restore

    @user.reload
    assert_equal @annual.id, @user.selected_billing_plan_id
    assert_equal bandwidth_before, @user.upload_bandwidth_kb
    assert_equal [@annual.id], @user.active_subscriptions.pluck(:billing_plan_id)
    assert_equal 'restored', outcome_for(rows, @user)
  end

  test "restore is idempotent" do
    downgrade!(@user)
    stub_stripe_listing([stripe_subscription('cus_one', 'premium')])
    ENV['APPLY'] = '1'
    run_restore
    Rake::Task['incident:restore_premium_from_stripe'].reenable
    rows = run_restore

    assert_equal 'ok_already_on_plan', outcome_for(rows, @user)
    assert_equal 1, @user.reload.active_subscriptions.count
  end

  test "restore leaves past_due subscribers for review" do
    downgrade!(@user)
    stub_stripe_listing([stripe_subscription('cus_one', 'premium', status: 'past_due')])
    ENV['APPLY'] = '1'
    rows = run_restore

    assert_equal @starter.id, @user.reload.selected_billing_plan_id
    assert_equal 'review_unhealthy_status', outcome_for(rows, @user)
  end

  test "restore never downgrades and reports local Premium users missing from Stripe" do
    other = users(:two)
    other.update_columns(stripe_customer_id: 'cus_two', selected_billing_plan_id: @premium.id)
    downgrade!(@user)
    stub_stripe_listing([stripe_subscription('cus_one', 'premium')])
    ENV['APPLY'] = '1'
    rows = run_restore

    assert_equal @premium.id, other.reload.selected_billing_plan_id
    assert_equal 'review_local_premium_without_stripe', outcome_for(rows, other)
  end

  test "restore gives a live subscription row back to a user whose downgrade only half-applied" do
    @user.active_subscriptions.update_all(end_date: 1.hour.ago) # plan kept, row end-dated
    stub_stripe_listing([stripe_subscription('cus_one', 'premium')])
    ENV['APPLY'] = '1'
    rows = run_restore

    assert_equal @premium.id, @user.reload.selected_billing_plan_id
    assert_equal 10_000_000, @user.upload_bandwidth_kb
    assert_equal 1, @user.active_subscriptions.count
    assert_equal 'repaired_subscription_row', outcome_for(rows, @user)
  end

  test "restore aborts when Stripe has nobody on a Premium price" do
    downgrade!(@user)
    stub_stripe_listing([stripe_subscription('cus_one', 'price_unknown')])
    ENV['APPLY'] = '1'
    ENV['REPORT'] = File.join(Dir.tmpdir, "restore_test_#{SecureRandom.hex(4)}.csv")

    assert_raises(SystemExit) { run_task('incident:restore_premium_from_stripe') }
    assert_equal @starter.id, @user.reload.selected_billing_plan_id
  end

  test "restore runs with a restricted key that can't read the Stripe account" do
    stub_request(:get, "#{STRIPE_BASE}/account").to_return(
      status: 403, body: { error: { type: 'invalid_request_error', message: 'Permission denied' } }.to_json
    )
    downgrade!(@user)
    stub_stripe_listing([stripe_subscription('cus_one', 'premium')])
    ENV['APPLY'] = '1'
    rows = run_restore

    assert_equal @premium.id, @user.reload.selected_billing_plan_id
    assert_equal 'restored', outcome_for(rows, @user)
  end

  test "restore skips a Premium price Stripe doesn't recognize and still restores the rest" do
    downgrade!(@user)
    stub_stripe_listing([stripe_subscription('cus_one', 'premium')])
    stub_request(:get, "#{STRIPE_BASE}/subscriptions")
      .with(query: hash_including(price: 'early-adopters'))
      .to_return(status: 400, body: { error: { type: 'invalid_request_error', message: 'No such price' } }.to_json)
    ENV['APPLY'] = '1'
    rows = run_restore

    assert_equal @premium.id, @user.reload.selected_billing_plan_id
    assert_equal 'restored', outcome_for(rows, @user)
  end

  test "LIMIT also caps repaired subscription rows" do
    other = users(:two)
    other.update_columns(stripe_customer_id: 'cus_two', selected_billing_plan_id: @premium.id)
    other.subscriptions.create!(billing_plan: @premium, start_date: 1.year.ago, end_date: 1.hour.ago)
    @user.active_subscriptions.update_all(end_date: 1.hour.ago)
    stub_stripe_listing([stripe_subscription('cus_one', 'premium'), stripe_subscription('cus_two', 'premium')])
    ENV['APPLY'] = '1'
    ENV['LIMIT'] = '1'
    rows = run_restore

    assert_equal 1, rows.count { |row| row['outcome'] == 'repaired_subscription_row' }
    assert_equal 1, rows.count { |row| row['outcome'] == 'restorable_over_limit' }
  end
end
