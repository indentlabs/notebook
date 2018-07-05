class CreateSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :billing_plan, index: true, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end
