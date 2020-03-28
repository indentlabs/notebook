class CreateLoreBelievers < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_believers do |t|
      t.references :lore, null: false, foreign_key: true
      t.integer :believer_id
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
