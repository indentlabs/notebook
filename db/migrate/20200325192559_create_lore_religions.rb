class CreateLoreReligions < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_religions do |t|
      t.references :lore, null: false, foreign_key: true
      t.references :religion, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
