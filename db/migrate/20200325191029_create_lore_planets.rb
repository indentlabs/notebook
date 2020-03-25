class CreateLorePlanets < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_planets do |t|
      t.references :lore, null: false, foreign_key: true
      t.references :planet, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
