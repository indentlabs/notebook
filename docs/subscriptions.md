# Subscriptions

When a user signs up, we automatically initialize a Stripe Customer object for them via Stripe's API,
and subscribe them to the free (starter) subscription on Stripe, charging $0.00/month.

When a user visits the subscriptions page and clicks to upgrade to Premium:

- We first check to see if they have a payment method saved on Stripe.
  - If they do, we update their Stripe Customer's subscription to the Premium plan they've selected
    (with the `change` method), with no changes to payment method.
  - If they don't have a payment method on Stripe, we redirect them to a page for inputting one.
  	- Upon submission, we kick off the `information_change` to save their payment method on Stripe
  	  _and_ change their subscription plan.

- When we subscribe someone to Premium, we do the following on our side to track their subscription:
  1. Look for any currently active subscriptions (`end_date > Today`) and update their `end_date` to
     `Datetime.now`.
  2. Create a new Subscription for the newly-selected plan, and set an `end_date` of 5 years from now.

When a user visits the subscriptions page and clicks to downgrade to Starter:

- We update their Stripe Customer object's subscription to Starter, so they are properly prorated for
  unused time and aren't billed on the next cycle.
- We end any current Subscriptions on our side and create a new Subscription for the `starter` plan.

# Billing
Since Stripe handles recurring subscriptions, we're just managing which plan they're subscribed to
on Stripe, who handles billing on time, prorating, refunds, etc.

# TODO

- Webhooks (for failed payments, successful payments, etc) are not implemented.
- Similarly, we should probably send an email to users after each of the above occurs.
- If a user's card is declined, we don't automatically downgrade them to starter (happens manually).
- There seems to be a bug somewhere where some users Subscriptions are ending early (and just need their
  `end_date` updated to a point in the distant future), but occurrences of this may just be from
  subscriptions that started before we began setting 5-year durations by default (from 31-day durations).
- It'd be very nice to abstract this out enough to support other payment methods like Paypal.
