# Incident: mass Premium downgrade by `data_integrity:subscription_synced_with_stripe`

## TL;DR

- **Local database only. Stripe was not touched.** On `master` (the code production runs),
  `SubscriptionService.cancel_all_existing_subscriptions` makes no Stripe calls. Affected
  customers are **almost certainly still being billed by Stripe** while they're locked out of
  Premium. That makes local restoration urgent.
- **Root cause (hypothesis 1, confirmed from code):** production runs `stripe` gem **15.1.0**.
  On current Stripe API versions, a retrieved `Stripe::Customer` no longer includes
  `subscriptions` (it has to be expanded explicitly). So `stripe_customer.subscriptions&.data || []`
  is always `[]`, every synced user hits `stripe_subscription.nil?`, and every one is downgraded.
  This is the same dead read that caused the parallel-subscription bug fixed on
  `tailwind-redesign` in 43902ce.
- Hypothesis 3 (plan ID vs price ID) is **not needed** to explain the incident, because the price
  comparison is never reached. Legacy Plan IDs also still work as Price IDs in Stripe. Still
  verify with `BillingPlan.pluck(:id, :name, :stripe_plan_id)`.
- **Recovery doesn't need an RDS restore.** The downgrade end-dated `subscriptions` rows
  instead of deleting them, so those rows already record who was downgraded and from which
  plan. An RDS point-in-time restore is still a useful cross-check.

## What `cancel_all_existing_subscriptions` did (master)

```ruby
def self.cancel_all_existing_subscriptions(user)
  user.update(selected_billing_plan_id: 1)
  user.active_subscriptions.each do |subscription|
    remove_subscription(user, subscription)   # upload_bandwidth_kb -= plan.bonus_bandwidth_kb
  end                                         # subscription.update(end_date: now)
end
```

| Question from handoff | Answer |
|---|---|
| Only local DB? | **Yes** |
| Calls Stripe / cancels / `cancel_at_period_end` / deletes? | **No** |
| Changes billing plan locally? | Yes, `selected_billing_plan_id = 1` (validated `update`) |
| Clears Stripe IDs? | No, `stripe_customer_id` untouched |
| Entitlements? | `subscriptions.end_date = now`; `upload_bandwidth_kb -= bonus_bandwidth_kb` (can go negative) |

Then it sent `UnsubscribedMailer.unsubscribed`, with the subject *"Update your payment method to
keep your Notebook.ai Premium features"*. That email wrongly tells customers their payment
method is invalid. The correction email must address that specifically.

## Things the handoff missed

1. **Early Adopters (plan 3) were probably hit too.** `BillingPlan::PREMIUM_IDS = [2,3,4,5,6]`.
   The task subtracts only free-for-life (2), so it synced plans **3**, 4, 5 and 6. Count them with
   `Subscription.where(billing_plan_id: 3, end_date: window).count`.
2. **Some of the "5 remaining" users may also have been hit.** `user.update` runs validations
   (e.g. `time_zone` must be present and valid). For an invalid user, both the plan change and
   the bandwidth deduction silently fail. Their subscription rows were still end-dated and they
   still got the email. The recovery task accounts for this and doesn't re-add their bandwidth.
3. **Tonight's run can do it again for anyone restored.** Keep the cron disabled everywhere
   until the fixed task (below) is deployed.
4. `user.last_sign_in_at.strftime` in the master task raises on users who never signed in,
   which crashes the run part-way. The downgrade count may therefore be smaller than the full
   Premium population, or split across several nights. Check Slack for multiple
   "N total accounts downgraded" lines.

## Reconstructing the affected set (read-only)

```ruby
window = Time.zone.parse('YYYY-MM-DD 00:55 UTC')..Time.zone.parse('YYYY-MM-DD HH:MM UTC')
Subscription.where(billing_plan_id: [3,4,5,6], end_date: window).group(:billing_plan_id).count
Subscription.where(billing_plan_id: [3,4,5,6], end_date: window).distinct.count(:user_id)
```

Take the window from the first and last "Automatically downgrading" Slack messages. The task
sleeps 1s per user, so thousands of users means a run of an hour or more. Keep the window tight,
because a legitimate cancellation inside it would look identical. Also cross-check the user set
against the Slack ledger and/or an RDS restore.

## Recovery: `rake incident:restore_mass_downgraded_premium`

`lib/tasks/incident_recovery.rake` is a dry run by default and writes a CSV report.

```bash
INCIDENT_START='2026-09-XX 00:55 UTC' INCIDENT_END='2026-09-XX 03:00 UTC' \
  bundle exec rake incident:restore_mass_downgraded_premium        # dry run + CSV
# review the CSV, then a small batch:
APPLY=1 LIMIT=5 INCIDENT_START=... INCIDENT_END=... bundle exec rake incident:restore_mass_downgraded_premium
# then everyone:
APPLY=1 INCIDENT_START=... INCIDENT_END=... bundle exec rake incident:restore_mass_downgraded_premium
```

For each user with a plan 3–6 subscription end-dated in the window, the task works as follows:

- Skips users that were deleted, have re-subscribed since, or are on another plan now.
- Lists their Stripe subscriptions (`Stripe::Subscription.list`, `status: all`).
- Restores the user **only** if Stripe has an `active`/`trialing` subscription on that plan's
  price. Restoring means: plan id back, the subscription's `end_date` back to
  `start_date.end_of_day + 10.years` (what `add_subscription` sets), and bonus bandwidth back.
  This is idempotent.
- Sends everyone else (past_due, unpaid, different price, no subscription, Stripe error) to
  `review_*` in the CSV for a human. Nobody is charged, and no Stripe object is created or changed.
- Prints the Stripe account id and whether the key is live, so you can confirm it's the
  production account before trusting results.
- Sends no emails. Send the correction/apology separately, after verification.

## Fixed sync task

`data_integrity:subscription_synced_with_stripe` on this branch now:

- lists subscriptions explicitly and checks all billable ones, not `.first`
- is **report-only unless `APPLY=1`**, so the cron line as written only reports
- treats a Stripe error as "skip and count", never "no subscription"
- collects all mismatches first and, before touching anyone, aborts if there were any Stripe
  errors or more than `min(10, 5%)` mismatches
- no longer crashes on a nil `last_sign_in_at`

This fix lives on `tailwind-redesign`, not `master`. Don't re-enable the cron until it's deployed.
