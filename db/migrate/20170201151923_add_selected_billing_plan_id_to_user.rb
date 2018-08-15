class AddSelectedBillingPlanIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :selected_billing_plan_id, :integer
  end
end
