class CreatePageUnlockPromoCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :page_unlock_promo_codes do |t|
      t.string :code
      t.string :page_types
      t.integer :uses_remaining
      t.integer :days_active

      t.timestamps
    end
  end
end
