class HardenSubscriptionsAgainstDoubleBilling < ActiveRecord::Migration[6.1]
  def up
    # Track which Stripe subscription a local subscription row corresponds to. This lets webhook
    # handlers and the billing audit task reconcile local state against Stripe (the source of
    # truth) and detect duplicates that slipped through.
    unless column_exists?(:subscriptions, :stripe_subscription_id)
      add_column :subscriptions, :stripe_subscription_id, :string
    end
    unless index_exists?(:subscriptions, :stripe_subscription_id)
      add_index :subscriptions, :stripe_subscription_id
    end

    # Make Stripe webhook processing idempotent: we should never process the same event twice.
    # First collapse any pre-existing duplicate log rows, then enforce uniqueness at the DB level.
    dedupe_stripe_event_logs!
    unless index_exists?(:stripe_event_logs, :event_id, unique: true)
      add_index :stripe_event_logs, :event_id, unique: true
    end
  end

  def down
    if index_exists?(:stripe_event_logs, :event_id, unique: true)
      remove_index :stripe_event_logs, :event_id
    end
    if index_exists?(:subscriptions, :stripe_subscription_id)
      remove_index :subscriptions, :stripe_subscription_id
    end
    if column_exists?(:subscriptions, :stripe_subscription_id)
      remove_column :subscriptions, :stripe_subscription_id
    end
  end

  private

  # Keep the earliest log row per event_id; remove the rest. Safe because these rows are an
  # append-only audit log with no downstream dependencies.
  def dedupe_stripe_event_logs!
    duplicate_ids = select_rows(<<~SQL).flatten
      SELECT id FROM stripe_event_logs
      WHERE event_id IS NOT NULL
        AND id NOT IN (
          SELECT MIN(id) FROM stripe_event_logs
          WHERE event_id IS NOT NULL
          GROUP BY event_id
        )
    SQL

    return if duplicate_ids.empty?

    execute("DELETE FROM stripe_event_logs WHERE id IN (#{duplicate_ids.join(',')})")
  end
end
