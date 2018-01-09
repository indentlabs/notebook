class CreateStripeEventLogs < ActiveRecord::Migration
  def change
    create_table :stripe_event_logs do |t|
      t.string :event_id
      t.string :event_type

      t.timestamps null: false
    end
  end
end
