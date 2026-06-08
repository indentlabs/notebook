namespace :billing do
  desc "Audit for duplicate active subscriptions (double-billing). Read-only."
  task audit: :environment do
    puts "== Local duplicate active subscriptions =="
    local_dupes = BillingAudit.users_with_multiple_active_subscriptions
    if local_dupes.empty?
      puts "  None found. 🎉"
    else
      local_dupes.each do |user_id, subscription_ids|
        puts "  User ##{user_id}: #{subscription_ids.size} active subscriptions (#{subscription_ids.join(', ')})"
      end
      puts "  #{local_dupes.size} affected user(s)."
    end

    unless Rails.env.test?
      puts "\n== Stripe customers with multiple live subscriptions =="
      puts "  (Run `rake billing:audit_stripe` for the Stripe-side scan; it makes API calls.)"
    end
  end

  desc "Audit Stripe directly for customers with more than one live subscription. Read-only, slow."
  task audit_stripe: :environment do
    BillingAudit.stripe_customers_with_multiple_subscriptions do |user, subscription_ids|
      puts "  User ##{user.id} (#{user.email}): #{subscription_ids.size} live Stripe subs (#{subscription_ids.join(', ')})"
    end
    puts "  Stripe scan complete."
  end

  desc "Repair local duplicate active subscriptions: keep the earliest, close the rest. Stripe-side " \
       "cleanup is a dry-run unless CONFIRM=1."
  task cleanup: :environment do
    confirm = ENV['CONFIRM'] == '1'

    puts "== Repairing local duplicate active subscriptions =="
    local_dupes = BillingAudit.users_with_multiple_active_subscriptions
    if local_dupes.empty?
      puts "  Nothing to repair locally."
    else
      local_dupes.each do |user_id, _ids|
        user = User.find(user_id)
        kept, closed = BillingAudit.collapse_local_subscriptions!(user)
        puts "  User ##{user_id}: kept ##{kept&.id}, closed #{closed.size} duplicate(s)."
      end
    end

    puts "\n== Stripe-side duplicate subscriptions =="
    puts "  Mode: #{confirm ? 'APPLY (cancelling extras)' : 'DRY RUN (set CONFIRM=1 to apply)'}"
    BillingAudit.stripe_customers_with_multiple_subscriptions do |user, subscription_ids|
      # Keep the oldest live subscription, flag/cancel the rest.
      extras = subscription_ids[1..] || []
      extras.each do |sub_id|
        if confirm
          Stripe::Subscription.cancel(sub_id)
          puts "  User ##{user.id}: cancelled extra Stripe sub #{sub_id}"
        else
          puts "  User ##{user.id}: WOULD cancel extra Stripe sub #{sub_id}"
        end
      end
    end
    puts "\n  NOTE: refunds for past double-charges are intentionally NOT automated. Review the " \
         "affected users above and issue refunds manually from the Stripe dashboard."
  end

  # Helpers shared by the tasks above. Kept here (rather than in app/) so they don't load in the
  # request path; they're only needed for ad-hoc maintenance.
  class BillingAudit
    # => { user_id => [subscription_id, ...], ... } for users with > 1 active subscription.
    def self.users_with_multiple_active_subscriptions
      Subscription.active
        .group_by(&:user_id)
        .select { |_user_id, subs| subs.size > 1 }
        .transform_values { |subs| subs.sort_by(&:created_at).map(&:id) }
    end

    # Keep the earliest active subscription for a user, close (end now) the rest.
    # Returns [kept_subscription, [closed_subscriptions]].
    def self.collapse_local_subscriptions!(user)
      actives = user.subscriptions.active.order(:created_at).to_a
      return [actives.first, []] if actives.size <= 1

      kept   = actives.first
      closed = actives[1..]
      closed.each { |sub| sub.update_columns(end_date: Time.now, updated_at: Time.now) }
      [kept, closed]
    end

    # Yields [user, [live_stripe_subscription_id, ...]] for each Stripe customer (mapped to a local
    # user) that has more than one live subscription. No-op in the test environment.
    def self.stripe_customers_with_multiple_subscriptions
      return if Rails.env.test?

      User.where.not(stripe_customer_id: [nil, '']).find_each do |user|
        customer = begin
          Stripe::Customer.retrieve(user.stripe_customer_id)
        rescue Stripe::StripeError
          next
        end

        live = (customer.subscriptions&.data || []).select do |sub|
          %w[active trialing past_due unpaid].include?(sub.status)
        end

        next if live.size <= 1

        ordered_ids = live.sort_by(&:created).map(&:id)
        yield(user, ordered_ids)
      end
    end
  end
end
