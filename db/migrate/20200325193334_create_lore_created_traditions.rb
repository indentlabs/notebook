class CreateLoreCreatedTraditions < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_created_traditions do |t|
      t.references :lore, null: false, foreign_key: true
      t.integer :created_tradition_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
