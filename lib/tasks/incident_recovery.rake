require 'csv'

namespace :incident do
  # Recovery for the mass downgrade caused by data_integrity:subscription_synced_with_stripe
  # reading `Stripe::Customer#subscriptions`, which current Stripe API versions no longer
  # include on retrieved customers. Every synced Premium user looked unsubscribed and was
  # run through SubscriptionService.cancel_all_existing_subscriptions, which only touches
  # OUR database:
  #
  #   * users.selected_billing_plan_id  -> 1 (Starter)
  #   * subscriptions.end_date          -> time of the run (rows are end-dated, not deleted)
  #   * users.upload_bandwidth_kb       -> reduced by the plan's bonus_bandwidth_kb
  #
  # Stripe subscriptions were NOT canceled, so the end-dated local subscription rows are
  # themselves a ledger of who was downgraded and from which plan. This task finds those
  # rows, checks each user against Stripe, and (only with APPLY=1) reverses exactly the
  # three changes above for users Stripe says are still paying for that plan.
  desc "Restore Premium users mass-downgraded by the Stripe sync task. " \
       "Requires INCIDENT_START and INCIDENT_END (e.g. '2026-09-20 00:55 UTC'). " \
       "Dry run by default; APPLY=1 restores. Writes a CSV report (REPORT=path)."
  task restore_mass_downgraded_premium: :environment do
    apply        = ENV['APPLY'] == '1'
    window_start = Time.zone.parse(ENV.fetch('INCIDENT_START') { abort "Set INCIDENT_START" })
    window_end   = Time.zone.parse(ENV.fetch('INCIDENT_END')   { abort "Set INCIDENT_END" })
    report_path  = ENV.fetch('REPORT', Rails.root.join('tmp', "premium_restore_#{Time.now.to_i}.csv").to_s)
    limit        = ENV['LIMIT']&.to_i # restore only the first N restorable users (for a small test batch)

    abort "INCIDENT_START must be before INCIDENT_END" unless window_start < window_end

    # Every plan the sync task would have touched: all Premium plans except free-for-life,
    # which isn't billed through Stripe.
    free_for_life_id = BillingPlan.find_by(stripe_plan_id: 'free-for-life')&.id
    synced_plan_ids  = BillingPlan::PREMIUM_IDS - [free_for_life_id]

    account = Stripe::Account.retrieve
    puts apply ? "APPLY mode: restorable users WILL be restored." : "Dry run: no changes will be made. Re-run with APPLY=1 to restore."
    puts "Stripe account #{account.id} (#{Stripe.api_key.to_s.start_with?('sk_live_') ? 'LIVE' : 'NOT LIVE'} key)"
    puts "Window: #{window_start.utc} .. #{window_end.utc}; plans: #{synced_plan_ids.inspect}"
    puts

    ended_subscriptions = Subscription
      .where(billing_plan_id: synced_plan_ids, end_date: window_start..window_end)
      .includes(:billing_plan)
      .order(:id)
      .group_by(&:user_id)

    counts   = Hash.new(0)
    restored = 0

    FileUtils.mkdir_p(File.dirname(report_path))
    CSV.open(report_path, 'w') do |csv|
      csv << %w[user_id email plan_id plan stripe_customer_id current_plan_id outcome stripe_statuses stripe_price_ids note]

      ended_subscriptions.each do |user_id, subscriptions|
        user         = User.with_deleted.find_by(id: user_id)
        subscription = subscriptions.max_by(&:start_date) # the one that was active when the task ran
        plan         = subscription.billing_plan

        row = lambda do |outcome, stripe_subs = [], note = nil|
          counts[outcome] += 1
          csv << [
            user_id, user&.email, plan.id, plan.name, user&.stripe_customer_id, user&.selected_billing_plan_id, outcome,
            stripe_subs.map(&:status).join(' '),
            stripe_subs.flat_map { |s| SubscriptionService.subscription_price_ids(s) }.uniq.join(' '),
            note
          ]
        end

        next row.call('skip_user_missing') if user.nil?
        next row.call('skip_user_deleted') if user.deleted?

        # Someone who has since re-subscribed or been changed by hand must not be touched.
        if user.active_subscriptions.where.not(id: subscription.id).exists?
          next row.call('skip_has_newer_subscription')
        end
        unless [1, nil, plan.id].include?(user.selected_billing_plan_id)
          next row.call('skip_plan_changed_since', [], "now on plan #{user.selected_billing_plan_id}")
        end

        sleep 0.1 unless Rails.env.test? # stay well under Stripe's rate limit
        begin
          stripe_subs = SubscriptionService.billable_stripe_subscriptions(user.stripe_customer_id)
        rescue Stripe::StripeError => e
          next row.call('review_stripe_error', [], "#{e.class}: #{e.message}")
        end

        matching = stripe_subs.select { |s| SubscriptionService.subscription_price_ids(s).include?(plan.stripe_plan_id) }
        healthy  = matching.select { |s| %w[active trialing].include?(s.status) }

        if healthy.empty?
          # Past-due / unpaid / no subscription / a different price: a human decides.
          outcome = if matching.any?
            'review_unhealthy_status'
          elsif stripe_subs.any?
            'review_different_price'
          else
            'review_no_stripe_subscription'
          end
          next row.call(outcome, stripe_subs)
        end

        if limit && restored >= limit
          next row.call('restorable_over_limit', stripe_subs)
        end

        # cancel_all_existing_subscriptions used validated `user.update`s. On a user that
        # fails validation (e.g. a nil time_zone) both the plan change AND the bandwidth
        # deduction silently failed, while the subscription rows were still end-dated.
        # Such users are still on their plan, so their bandwidth must not be re-added.
        bandwidth_was_deducted = user.selected_billing_plan_id != plan.id
        bandwidth_note = bandwidth_was_deducted ? nil : 'still on plan (validation failed); bandwidth not re-added'

        if apply
          User.transaction do
            user.lock!
            # Reverse cancel_all_existing_subscriptions exactly. update_column skips
            # validations, matching add_subscription (some users have invalid records).
            user.update_column(:selected_billing_plan_id, plan.id)
            subscriptions.each do |ended|
              # add_subscription creates rows ending end_of_day + 10 years after the start.
              ended.update_column(:end_date, ended.start_date.end_of_day + 10.years)
              if bandwidth_was_deducted
                user.update_column(:upload_bandwidth_kb, user.upload_bandwidth_kb + ended.billing_plan.bonus_bandwidth_kb)
              end
            end
          end
          restored += 1
          row.call('restored', stripe_subs, bandwidth_note)
        else
          restored += 1
          row.call('would_restore', stripe_subs, bandwidth_note)
        end
      end
    end

    puts "#{ended_subscriptions.length} users had a synced Premium subscription end-dated in the window."
    counts.sort.each { |outcome, count| puts "  #{outcome.ljust(32)} #{count}" }
    puts
    puts "Report written to #{report_path}"
    puts "No correction emails were sent; send those separately once restoration is verified."
  end
end
