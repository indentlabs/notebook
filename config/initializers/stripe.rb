StripeEvent.configure do |events|
  events.subscribe 'invoice.payment_succeeded' do |event|
    StripeEventLog.create(event_id: event.id, event_type: event.type)
    StripeInvoiceEvents.new(event).payment_succeeded
  end

  events.subscribe 'invoice.payment_failed' do |event|
    StripeEventLog.create(event_id: event.id, event_type: event.type)
    StripeInvoiceEvents.new(event).payment_failed
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
