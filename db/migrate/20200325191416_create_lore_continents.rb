class CreateLoreContinents < ActiveRecord::Migration[6.0]
  def change
    create_table :lore_continents do |t|
      t.references :lore, null: false, foreign_key: true
      t.references :continent, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
