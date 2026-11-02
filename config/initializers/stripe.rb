# The Stripe API version our billing code is written against. Stripe changes
# the shape of its responses between API versions (fields get renamed or
# removed), and the stripe gem moves to a new version with each major release.
# Pinning it here means a gem upgrade can't silently change what Stripe sends
# us; test/lint/stripe_api_version_test.rb fails when the two drift apart, as
# the prompt to check the billing pages against Stripe's changelog first.
STRIPE_API_VERSION = '2025-04-30.basil'.freeze
Stripe.api_version = STRIPE_API_VERSION

StripeEvent.configure do |events|
  events.subscribe 'invoice.payment_succeeded' do |event|
    StripeEventLog.create(event_id: event.id, event_type: event.type)
    #StripeInvoiceEvents.new(event).payment_succeeded
  end

  events.subscribe 'invoice.payment_failed' do |event|
    StripeEventLog.create(event_id: event.id, event_type: event.type)
    #StripeInvoiceEvents.new(event).payment_failed
  end

  events.subscribe 'account.updated' do |event|
    StripeEventLog.create(event_id: event.id, event_type: event.type)
  end

  events.subscribe 'charge.failed' do |event|
    StripeEventLog.create(event_id: event.id, event_type: event.type)
  end

  events.subscribe 'charge.succeeded' do |event|
    StripeEventLog.create(event_id: event.id, event_type: event.type)
  end

  events.subscribe 'charge.updated' do |event|
    StripeEventLog.create(event_id: event.id, event_type: event.type)
  end

  events.subscribe 'customer.subscription.trial_will_end' do |event|
    StripeEventLog.create(event_id: event.id, event_type: event.type)
  end
end
