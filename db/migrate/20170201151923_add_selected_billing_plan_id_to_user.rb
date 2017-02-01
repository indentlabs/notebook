class AddSelectedBillingPlanIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :selected_billing_plan_id, :integer
  end
end
