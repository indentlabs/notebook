class CreateDeityRelics < ActiveRecord::Migration
  def change
    create_table :deity_relics do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true
      t.integer :relic_id

      t.timestamps null: false
    end
  end
end
