# Incident: mass Premium downgrade by `data_integrity:subscription_synced_with_stripe`

Production runs the `tailwind-redesign` branch.

## TL;DR

- **Local database only. Stripe was not touched.** `SubscriptionService.cancel_all_existing_subscriptions`
  makes no Stripe calls, on this branch and on `master`, and the Stripe webhook handlers only log
  events. Affected customers are **almost certainly still being billed** while locked out of Premium.
- **So Stripe is the source of truth for recovery.** List every Premium subscription in Stripe and
  put the matching user back on that plan: `rake incident:restore_premium_from_stripe`. No incident
  window, Slack history, or RDS restore is needed for the Stripe-billed users.

## What `cancel_all_existing_subscriptions` does

```ruby
def self.cancel_all_existing_subscriptions(user)
  user.update(selected_billing_plan_id: 1)            # validated update
  user.active_subscriptions.each do |subscription|
    remove_subscription(user, subscription)           # upload_bandwidth_kb -= plan.bonus_bandwidth_kb
  end                                                 # subscription.update(end_date: now)
end
```

It doesn't cancel, delete, or set `cancel_at_period_end` on anything in Stripe, and it doesn't
clear Stripe IDs. It then sent `UnsubscribedMailer.unsubscribed`, with the subject *"Update your
payment method to keep your Notebook.ai Premium features"*. That email wrongly tells customers
their card is no longer valid, so the correction email needs to say their card is fine.

## Which sync code ran

Two versions of the sync task have existed on this branch:

- **Before 48ebc17 (Aug 8, 2026):** read `Stripe::Customer#subscriptions`. With stripe gem 15.1.0
  that is never populated, so **every** synced user looked unsubscribed and was downgraded in one
  night. (It could crash part-way on a nil `last_sign_in_at`, spreading this over several nights.)
- **48ebc17 and later:** lists subscriptions correctly, but aborts only after downgrading 20% of
  Premium users, and the counter resets every night. If this version still found a false mismatch
  for most users (say, a `stripe_plan_id` that doesn't match Stripe's price IDs, or the wrong Stripe
  account/key on the new server), it would take ~20% of the remaining Premium users each night.
  That would reach "5 left" in about a month.

`rake incident:premium_downgrades_by_day` shows which one happened: one big spike, or a ~20%
decay over many nights. The restore task's dry run also rules the second cause in or out. It
prints every Stripe price with subscriber counts next to the matching billing plan, and aborts if
no Premium price in `billing_plans` has any Stripe subscribers.

## Recovery: `rake incident:restore_premium_from_stripe`

```bash
bundle exec rake incident:premium_downgrades_by_day                    # when did it happen?
bundle exec rake incident:restore_premium_from_stripe                  # dry run, writes a CSV
APPLY=1 LIMIT=5 bundle exec rake incident:restore_premium_from_stripe  # small test batch
APPLY=1 bundle exec rake incident:restore_premium_from_stripe          # everyone
```

The task pages through all billable Stripe subscriptions, one listing per status. For each
customer with a subscription on a Premium price (plans 3–6):

| Outcome | Meaning |
|---|---|
| `restored` / `would_restore` | Active/trialing on a Premium price, user on Starter locally. Plan set, bonus bandwidth re-added, a live subscription row created, the same local changes `add_subscription` makes without its Stripe sync. |
| `repaired_subscription_row` | User kept their plan (the validated downgrade silently failed) but lost their live subscription row. Row recreated; bandwidth untouched. |
| `ok_already_on_plan` | Nothing to do. Re-running is safe. |
| `review_unhealthy_status` | Only past_due/unpaid/incomplete in Stripe. A human decides. |
| `review_plan_differs` / `review_multiple_premium_plans` | Local Premium plan differs from Stripe, or Stripe bills several Premium plans. |
| `review_no_matching_user` / `review_multiple_users` | The Stripe customer maps to 0 or 2+ users. |
| `review_local_premium_without_stripe` | Premium locally, no Premium Stripe subscription. Reported, **never downgraded**. |
| `review_downgraded_without_stripe` | Lost a Premium row in the last `LOOKBACK_DAYS` (default 120), no Stripe subscription. For example, hand-granted Premium, which Stripe can't restore. |

The task never downgrades anyone, never writes to Stripe, and never sends email. Every row
includes `last_premium_row_ended`. That separates incident victims from people who cancelled
in the app long ago but were still billed. The cancel flow didn't reach Stripe before Aug 8, so
there may be some of those. They're paying, so restoring them is defensible, but they may also
want refunds.

## Sync task

`data_integrity:subscription_synced_with_stripe` is now report-only unless `APPLY=1`. It skips
users on Stripe errors instead of treating them as unsubscribed. It collects every mismatch
before touching anyone, and aborts if there are any Stripe errors or more than min(10, 5%)
mismatches. Keep the cron disabled until you've seen a few clean report-only runs.
