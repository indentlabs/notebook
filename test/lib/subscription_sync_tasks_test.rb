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
    Rake::Task['incident:restore_mass_downgraded_premium'].reenable

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
    @env_backup = ENV.to_h.slice('APPLY', 'INCIDENT_START', 'INCIDENT_END', 'REPORT', 'LIMIT')
  end

  def teardown
    %w[APPLY INCIDENT_START INCIDENT_END REPORT LIMIT].each { |key| ENV.delete(key) }
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

  # incident:restore_mass_downgraded_premium

  def simulate_incident!(at: 2.hours.ago)
    travel_to(at) { SubscriptionService.cancel_all_existing_subscriptions(@user) }
    ENV['INCIDENT_START'] = (at - 5.minutes).iso8601
    ENV['INCIDENT_END']   = (at + 5.minutes).iso8601
    ENV['REPORT']         = File.join(Dir.tmpdir, "restore_test_#{SecureRandom.hex(4)}.csv")
  end

  def report_rows
    CSV.read(ENV['REPORT'], headers: true)
  end

  test "restore dry run changes nothing and reports the user as restorable" do
    simulate_incident!
    stub_subscriptions('cus_one', [subscription_json('premium')])
    run_task('incident:restore_mass_downgraded_premium')

    assert_equal @starter.id, @user.reload.selected_billing_plan_id
    assert_equal 'would_restore', report_rows.first['outcome']
  end

  test "restore with APPLY=1 exactly reverses the downgrade" do
    bandwidth_before = @user.upload_bandwidth_kb
    simulate_incident!
    assert_equal @starter.id, @user.reload.selected_billing_plan_id
    stub_subscriptions('cus_one', [subscription_json('premium')])

    ENV['APPLY'] = '1'
    run_task('incident:restore_mass_downgraded_premium')

    @user.reload
    assert_equal @premium.id, @user.selected_billing_plan_id
    assert_equal bandwidth_before, @user.upload_bandwidth_kb
    assert_equal 1, @user.active_subscriptions.count
    assert_equal 'restored', report_rows.first['outcome']
  end

  test "restore leaves users without a live Stripe subscription for review" do
    simulate_incident!
    stub_subscriptions('cus_one', [subscription_json('premium', status: 'past_due')])
    ENV['APPLY'] = '1'
    run_task('incident:restore_mass_downgraded_premium')

    assert_equal @starter.id, @user.reload.selected_billing_plan_id
    assert_equal 'review_unhealthy_status', report_rows.first['outcome']
  end

  test "restore ignores subscriptions ended outside the incident window" do
    simulate_incident!(at: 3.days.ago)
    ENV['INCIDENT_START'] = 1.day.ago.iso8601
    ENV['INCIDENT_END']   = Time.current.iso8601
    ENV['APPLY'] = '1'
    run_task('incident:restore_mass_downgraded_premium')

    assert_equal @starter.id, @user.reload.selected_billing_plan_id
    assert_empty report_rows
  end
end
