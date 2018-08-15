class AddBonusBandwidthToBillingPlan < ActiveRecord::Migration[4.2]
  def change
    add_column :billing_plans, :bonus_bandwidth_kb, :integer, default: 0
  end
end
