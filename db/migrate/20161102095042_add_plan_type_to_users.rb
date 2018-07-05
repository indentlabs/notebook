class AddPlanTypeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :plan_type, :string
  end
end
