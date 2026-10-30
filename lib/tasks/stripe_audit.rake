namespace :stripe do
  desc "Find customers with parallel (duplicate) Stripe subscriptions. " \
       "Dry-run by default; run with APPLY=1 to cancel the duplicates, " \
       "keeping one subscription per customer (preferring the oldest one " \
       "on the user's currently selected plan). Canceled duplicates are " \
       "prorated, so unused time is credited to the customer's balance. " \
       "Refunds for past double-charges are NOT issued automatically."
  task audit_parallel_subscriptions: :environment do
    apply = ENV['APPLY'] == '1'
    puts apply ? "APPLY mode: duplicate subscriptions WILL be canceled." : "Dry run: no changes will be made. Re-run with APPLY=1 to cancel duplicates."
    puts

    # Enumerate all billable subscriptions Stripe-side (one paginated listing
    # per status) instead of hitting the API once per user.
    subscriptions_by_customer = Hash.new { |hash, key| hash[key] = [] }
    SubscriptionService::BILLABLE_STRIPE_STATUSES.each do |status|
      Stripe::Subscription.list(status: status, limit: 100).auto_paging_each do |subscription|
        subscriptions_by_customer[subscription.customer] << subscription
      end
    end

    affected = subscriptions_by_customer.select { |_customer_id, subscriptions| subscriptions.length > 1 }
    puts "#{subscriptions_by_customer.length} customers with billable subscriptions; #{affected.length} with parallel subscriptions."
    puts

    canceled_count = 0
    affected.sort_by { |_customer_id, subscriptions| -subscriptions.length }.each do |customer_id, subscriptions|
      user = User.find_by(stripe_customer_id: customer_id)
      selected_price = user && BillingPlan.find_by(id: user.selected_billing_plan_id)&.stripe_plan_id

      # Keep the healthiest/oldest subscription on the user's selected plan so
      # their original billing anchor (and anything they've already paid for)
      # survives; if none matches, keep the healthiest/oldest one outright.
      sorted = SubscriptionService.prioritize_subscriptions_to_keep(subscriptions)
      keeper = sorted.find { |subscription| SubscriptionService.subscription_price_ids(subscription).include?(selected_price) }
      keeper ||= sorted.first
      duplicates = sorted.reject { |subscription| subscription.id == keeper.id }

      puts "Customer #{customer_id} (#{user ? "user ##{user.id} #{user.email}, selected plan: #{selected_price || 'none'}" : 'NO MATCHING USER'})"
      puts "  KEEP   #{keeper.id} [#{keeper.status}] prices=#{SubscriptionService.subscription_price_ids(keeper).join(',')} created=#{Time.at(keeper.created).utc}"
      duplicates.each do |duplicate|
        puts "  CANCEL #{duplicate.id} [#{duplicate.status}] prices=#{SubscriptionService.subscription_price_ids(duplicate).join(',')} created=#{Time.at(duplicate.created).utc}"
        if apply
          Stripe::Subscription.cancel(duplicate.id, prorate: true)
          canceled_count += 1
        end
      end
      puts
    end

    if apply
      puts "Canceled #{canceled_count} duplicate subscriptions."
      puts "NOTE: unused time was credited to each customer's Stripe balance. Refunds for past double-charges must be issued manually from the Stripe dashboard."
    end
  end
end
