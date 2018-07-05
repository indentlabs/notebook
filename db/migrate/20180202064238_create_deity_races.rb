class CreateDeityRaces < ActiveRecord::Migration[4.2]
  def change
    create_table :deity_races do |t|
      t.references :deity, index: true, foreign_key: true
      t.references :race, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
