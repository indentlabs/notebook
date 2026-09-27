require 'csv'

namespace :incident do
  # Recovery for the mass Premium downgrade by data_integrity:subscription_synced_with_stripe.
  # That task downgraded users via SubscriptionService.cancel_all_existing_subscriptions,
  # which only touches OUR database (plan -> Starter, subscription rows end-dated, bonus
  # bandwidth removed) and never Stripe. So Stripe still knows exactly who is paying for
  # what, and is used here as the source of truth.
  #
  # For every Stripe subscription on a Premium price, make sure the matching Notebook.ai
  # user is on that plan. This only ever UPGRADES users back to what Stripe says they pay
  # for. It never downgrades anyone, never writes to Stripe, and never sends email.
  # Anything ambiguous is written to the CSV report for a human instead of being changed.
  desc "Restore Premium plans for users Stripe says are paying for Premium. " \
       "Dry run by default; APPLY=1 restores (LIMIT=N for a small batch). Writes a CSV report (REPORT=path)."
  task restore_premium_from_stripe: :environment do
    apply       = ENV['APPLY'] == '1'
    limit       = ENV['LIMIT']&.to_i
    lookback    = ENV.fetch('LOOKBACK_DAYS', '120').to_i.days
    report_path = ENV.fetch('REPORT', Rails.root.join('tmp', "premium_restore_#{Time.now.to_i}.csv").to_s)

    # The plans the sync task could have downgraded: every Premium plan except
    # free-for-life, which isn't billed through Stripe.
    free_for_life_id    = BillingPlan.find_by(stripe_plan_id: 'free-for-life')&.id
    plans_by_price      = BillingPlan.where(id: BillingPlan::PREMIUM_IDS - [free_for_life_id]).index_by(&:stripe_plan_id)
    synced_plan_ids     = plans_by_price.values.map(&:id)
    restorable_statuses = %w[active trialing]

    # Production uses a restricted key (rk_live_...) that can't read the account, so
    # this is informational only; the price counts below are the real sanity check.
    account_id = begin
      Stripe::Account.retrieve.id
    rescue Stripe::PermissionError
      'unavailable (restricted key)'
    end
    live_key = Stripe.api_key.to_s.start_with?('sk_live_', 'rk_live_')
    puts apply ? "APPLY mode: users WILL be restored." : "Dry run: no changes will be made. Re-run with APPLY=1 to restore."
    puts "Stripe account #{account_id} (#{live_key ? 'LIVE' : 'NOT LIVE'} key)"
    puts "Premium prices: #{plans_by_price.map { |price, plan| "#{price} => plan #{plan.id}" }.join(', ')}"
    puts

    # Only list subscriptions on Premium prices, one paginated listing per price and
    # status. Listing every billable subscription (including every $0 'starter' one)
    # held hundreds of thousands of objects in memory and took down the box it ran on.
    subscriptions_by_id = {}
    plans_by_price.each_key do |price|
      SubscriptionService::BILLABLE_STRIPE_STATUSES.each do |status|
        listed = 0
        Stripe::Subscription.list(price: price, status: status, limit: 100).auto_paging_each do |subscription|
          subscriptions_by_id[subscription.id] = subscription # a sub on two Premium prices is listed twice
          listed += 1
          puts "  ...#{listed} #{price} (#{status}) so far" if (listed % 1000).zero?
        end
        puts "  Listed #{listed} #{price} (#{status}) subscriptions"
      rescue Stripe::InvalidRequestError => e
        # e.g. a price that doesn't exist on this Stripe account (early-adopters may not)
        puts "  WARNING: couldn't list #{price} (#{status}) subscriptions: #{e.message}"
      end
    end
    subscriptions_by_customer = subscriptions_by_id.values.group_by(&:customer)

    # Every price on the listed subscriptions, so a Premium subscription that also carries
    # an unrecognized price stands out. (Subscriptions ONLY on unknown prices aren't
    # listed at all now; the abort below still catches a wholesale plan/price mismatch.)
    price_counts = Hash.new(0)
    subscriptions_by_customer.each_value do |subscriptions|
      subscriptions.each { |s| SubscriptionService.subscription_price_ids(s).each { |price| price_counts[price] += 1 } }
    end
    puts "Billable Stripe subscriptions by price:"
    price_counts.sort_by { |_, count| -count }.each do |price, count|
      plan = plans_by_price[price] || BillingPlan.find_by(stripe_plan_id: price)
      puts "  #{price.ljust(40)} #{count.to_s.rjust(6)}  #{plan ? "plan #{plan.id} (#{plan.name})" : 'UNKNOWN PRICE, not in billing_plans'}"
    end
    puts

    if plans_by_price.keys.none? { |price| price_counts.key?(price) }
      abort "ABORTING: no Stripe subscriptions on any Premium price. Wrong Stripe account/key, or " \
            "billing_plans.stripe_plan_id doesn't match Stripe's price IDs. Nothing was changed."
    end

    # users.stripe_customer_id isn't indexed, so one lookup per customer would be a full
    # scan of the users table each time. Fetch them all in a few large batches instead.
    users_by_customer = subscriptions_by_customer.keys.each_slice(5_000).flat_map do |customer_ids|
      User.where(stripe_customer_id: customer_ids).to_a
    end.group_by(&:stripe_customer_id)
    puts "Matched #{users_by_customer.size} of #{subscriptions_by_customer.size} Stripe customers to users."
    puts

    counts                 = Hash.new(0)
    restored               = 0
    premium_customer_ids   = Set.new # customers with a Premium Stripe subscription, for the leftovers report

    FileUtils.mkdir_p(File.dirname(report_path))
    CSV.open(report_path, 'w') do |csv|
      csv << %w[outcome user_id email stripe_customer_id current_plan_id stripe_plan_id stripe_statuses stripe_price_ids last_premium_row_ended note]

      write = lambda do |outcome, user: nil, customer_id: nil, plan: nil, subs: [], note: nil|
        counts[outcome] += 1
        last_ended = user && user.subscriptions.where(billing_plan_id: synced_plan_ids).where('end_date <= ?', Time.current).maximum(:end_date)
        csv << [
          outcome, user&.id, user&.email, customer_id || user&.stripe_customer_id, user&.selected_billing_plan_id, plan&.id,
          subs.map(&:status).join(' '),
          subs.flat_map { |s| SubscriptionService.subscription_price_ids(s) }.uniq.join(' '),
          last_ended&.utc&.iso8601, note
        ]
      end

      subscriptions_by_customer.each do |customer_id, subscriptions|
        premium_subs = subscriptions.select do |s|
          SubscriptionService.subscription_price_ids(s).any? { |price| plans_by_price.key?(price) }
        end
        next if premium_subs.empty? # Starter-only or unrelated customers: nothing to restore
        premium_customer_ids << customer_id

        users = users_by_customer.fetch(customer_id, [])
        next write.call('review_no_matching_user', customer_id: customer_id, subs: premium_subs) if users.empty?
        next write.call('review_multiple_users', customer_id: customer_id, subs: premium_subs, note: "users #{users.map(&:id).join(' ')}") if users.many?
        user = users.first

        healthy_plans = premium_subs
          .select { |s| restorable_statuses.include?(s.status) }
          .flat_map { |s| SubscriptionService.subscription_price_ids(s) }
          .filter_map { |price| plans_by_price[price] }
          .uniq

        if healthy_plans.empty?
          # Only past_due / unpaid / incomplete: they may be about to churn, so a human decides.
          next write.call('ok_already_on_plan', user: user, subs: premium_subs) if synced_plan_ids.include?(user.selected_billing_plan_id)
          next write.call('review_unhealthy_status', user: user, subs: premium_subs)
        end

        if healthy_plans.map(&:id).include?(user.selected_billing_plan_id)
          plan = plans_by_price.values.find { |p| p.id == user.selected_billing_plan_id }
          next write.call('ok_already_on_plan', user: user, plan: plan, subs: premium_subs) if user.active_subscriptions.where(billing_plan_id: plan.id).exists?

          # A user whose validated downgrade silently failed kept their plan (and bandwidth)
          # but had their subscription row end-dated. Give them a live row back.
          # Counts toward LIMIT like a restore, so a LIMIT=N test batch writes at most N users.
          next write.call('restorable_over_limit', user: user, plan: plan, subs: premium_subs) if limit && restored >= limit
          user.subscriptions.create!(billing_plan: plan, start_date: DateTime.now, end_date: DateTime.now.end_of_day + 10.years) if apply
          restored += 1
          next write.call(apply ? 'repaired_subscription_row' : 'would_repair_subscription_row', user: user, plan: plan, subs: premium_subs)
        end

        next write.call('review_multiple_premium_plans', user: user, subs: premium_subs) if healthy_plans.many?
        plan = healthy_plans.first

        # Premium locally on a different plan than Stripe bills for (or free-for-life).
        next write.call('review_plan_differs', user: user, plan: plan, subs: premium_subs) if BillingPlan::PREMIUM_IDS.include?(user.selected_billing_plan_id)

        next write.call('restorable_over_limit', user: user, plan: plan, subs: premium_subs) if limit && restored >= limit

        if apply
          User.transaction do
            user.lock!
            # Mirrors the local half of SubscriptionService.add_subscription, WITHOUT its
            # Stripe sync (the Stripe subscription is already correct) or referral bonuses.
            # update_column skips validations, as add_subscription does.
            user.update_column(:selected_billing_plan_id, plan.id)
            user.update_column(:upload_bandwidth_kb, user.upload_bandwidth_kb + plan.bonus_bandwidth_kb)
            unless user.active_subscriptions.where(billing_plan_id: plan.id).exists?
              user.subscriptions.create!(billing_plan: plan, start_date: DateTime.now, end_date: DateTime.now.end_of_day + 10.years)
            end
          end
        end
        restored += 1
        write.call(apply ? 'restored' : 'would_restore', user: user, plan: plan, subs: premium_subs)
      end

      # Leftovers Stripe can't vouch for, for a human to look at.
      # Users still Premium locally with no Premium Stripe subscription:
      User.where(selected_billing_plan_id: synced_plan_ids).find_each do |user|
        next if premium_customer_ids.include?(user.stripe_customer_id)
        write.call('review_local_premium_without_stripe', user: user)
      end
      # Recently downgraded users with no Premium Stripe subscription (e.g. Premium granted
      # by hand). Stripe-based recovery can't restore these; the DB history can.
      recently_ended_user_ids = Subscription
        .where(billing_plan_id: synced_plan_ids, end_date: lookback.ago..Time.current)
        .distinct.pluck(:user_id)
      User.where(id: recently_ended_user_ids).find_each do |user|
        next if premium_customer_ids.include?(user.stripe_customer_id)
        next if synced_plan_ids.include?(user.selected_billing_plan_id) # already reported above
        write.call('review_downgraded_without_stripe', user: user)
      end
    end

    puts "Outcomes:"
    counts.sort.each { |outcome, count| puts "  #{outcome.ljust(40)} #{count}" }
    puts
    puts "Report written to #{report_path}"
    puts "No emails were sent and nothing was written to Stripe."
  end

  desc "Count Premium subscription rows end-dated per day, to see when the downgrades happened."
  task premium_downgrades_by_day: :environment do
    lookback = ENV.fetch('LOOKBACK_DAYS', '120').to_i.days
    Subscription
      .where(billing_plan_id: BillingPlan::PREMIUM_IDS, end_date: lookback.ago..Time.current)
      .group(Arel.sql('DATE(end_date)')).group(:billing_plan_id).count
      .sort_by { |(date, plan_id), _| [date.to_s, plan_id] }
      .each { |(date, plan_id), count| puts "#{date}  plan #{plan_id}  #{count}" }
  end
end
