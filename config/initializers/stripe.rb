StripeEvent.configure do |events|
  # Stripe delivers webhooks at-least-once, so every handler must be safe to skip on redelivery.
  # StripeEventLog.record_once is the dedup gate: it returns true only the first time we see an
  # event id (backed by a unique index), so the block body runs exactly once per real event.
  process_once = lambda do |event, &block|
    if StripeEventLog.record_once(event)
      block.call
    end
  end

  events.subscribe 'invoice.payment_succeeded' do |event|
    process_once.call(event) do
      StripeInvoiceEvents.new(event).payment_succeeded
    end
  end

  events.subscribe 'invoice.payment_failed' do |event|
    process_once.call(event) do
      StripeInvoiceEvents.new(event).payment_failed
    end
  end

  # Reconcile local state when a subscription is cancelled/ended on Stripe's side. This is the
  # safety net that downgrades a user even if the cancellation didn't originate in our app.
  events.subscribe 'customer.subscription.deleted' do |event|
    process_once.call(event) do
      StripeSubscriptionEvents.new(event).deleted
    end
  end

  events.subscribe 'account.updated' do |event|
    process_once.call(event) { }
  end

  events.subscribe 'charge.failed' do |event|
    process_once.call(event) { }
  end

  events.subscribe 'charge.succeeded' do |event|
    process_once.call(event) { }
  end

  events.subscribe 'charge.updated' do |event|
    process_once.call(event) { }
  end

  events.subscribe 'customer.subscription.trial_will_end' do |event|
    process_once.call(event) { }
  end
end
