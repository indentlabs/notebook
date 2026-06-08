class StripeEventLog < ApplicationRecord
  # Records that we've seen a Stripe event, exactly once.
  #
  # Returns true the first time a given event id is seen (the caller should process the event)
  # and false on any subsequent delivery of the same event (the caller should skip it). Stripe
  # delivers webhooks at-least-once, so handlers must be idempotent; this is the dedup gate.
  #
  # Relies on the unique index on event_id to stay correct even under concurrent deliveries.
  def self.record_once(event)
    create!(event_id: event.id, event_type: event.type)
    true
  rescue ActiveRecord::RecordNotUnique
    false
  end
end
