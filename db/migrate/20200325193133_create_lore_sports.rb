class CreateLoreSports < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_sports do |t|
      t.references :lore, null: false, foreign_key: true
      t.references :sport, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
