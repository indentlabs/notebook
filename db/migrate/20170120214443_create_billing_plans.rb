class CreateBillingPlans < ActiveRecord::Migration
  def change
    create_table :billing_plans do |t|
      t.string :name
      t.string :stripe_plan_id
      t.integer :monthly_cents
      t.boolean :available
      t.boolean :allows_core_content
      t.boolean :allows_extended_content
      t.boolean :allows_collective_content
      t.boolean :allows_collaboration
      t.integer :universe_limit

      t.timestamps null: false
    end
  end
end
