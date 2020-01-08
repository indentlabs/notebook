class AddBillingIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :subscriptions, [:user_id, :start_date, :end_date]
    add_index :promotions,    [:user_id, :expires_at]
  end
end
