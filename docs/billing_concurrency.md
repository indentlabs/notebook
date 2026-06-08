# Billing concurrency & double-billing prevention

This documents how the app prevents the "double subscription / double charge" class of bug that
happens when a user submits a plan change twice (e.g. double-clicking while the site is slow).

## The failure mode

Changing a plan runs `cancel existing` then `add new`. Previously nothing serialized this, and the
Stripe sync read "does this customer already have a subscription?" before creating one. Two
concurrent requests could both read "no subscription" and both call `Stripe::Subscription.create`,
producing two live Stripe subscriptions (two charges) and two overlapping local `Subscription`
rows. The same check-then-act shape existed in promo-code redemption and the PayPal job.

## Layered defenses (in order of importance)

1. **Pessimistic per-user lock.** `SubscriptionService.change_plan` / `add_subscription` wrap the
   whole cancel+add in `user.with_lock` (`SELECT ... FOR UPDATE`), so concurrent plan changes for a
   user run one at a time. This is the primary fix.
2. **Idempotency guard.** Inside the lock we no-op if the user is already actively subscribed to the
   requested plan, so retries are safe.
3. **Stripe idempotency keys.** Every `Stripe::Subscription.create/modify` carries an
   `idempotency_key` (`SubscriptionService.stripe_idempotency_key`), so even a request that somehow
   bypasses the lock won't create a second subscription within Stripe's dedup window.
4. **Model invariant.** `Subscription` validates that a user has at most one *active* subscription
   (`end_date` in the future). Second layer for any non-`change_plan` creation path.
5. **Idempotent webhooks.** `StripeEventLog.record_once` (backed by a unique index on `event_id`)
   makes every webhook handler run exactly once. `customer.subscription.deleted` reconciles local
   state against Stripe (the source of truth).
6. **UI guard.** Plan-change links disable themselves on click (`.js-plan-change` in `billing.js`).

The same `with_lock` + claim pattern is applied to `PageUnlockPromoCode#activate!` and
`PayPalPrepayProcessingJob`.

## Auditing / cleanup

`rake billing:audit` (read-only) reports users with more than one active local subscription.
`rake billing:audit_stripe` scans Stripe directly. `rake billing:cleanup` collapses local
duplicates (keep earliest, close the rest); Stripe-side cancellation is a dry run unless `CONFIRM=1`.
Refunds for past double-charges are intentionally **not** automated — issue them manually after review.

## Recommended follow-up (Postgres-only hard guarantee)

The strongest guarantee is a database-level exclusion constraint preventing overlapping
subscription ranges per user. It is **not** in the migration because dev/test run SQLite (which
can't express it) and because it requires existing overlaps to be cleaned up first
(`rake billing:cleanup`). Once production data is clean, add (Postgres):

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;
ALTER TABLE subscriptions
  ADD CONSTRAINT no_overlapping_subscriptions_per_user
  EXCLUDE USING gist (user_id WITH =, tsrange(start_date, end_date) WITH &&)
  WHERE (start_date IS NOT NULL AND end_date IS NOT NULL);
```
