class CreateLoreVehicles < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_vehicles do |t|
      t.references :lore, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
