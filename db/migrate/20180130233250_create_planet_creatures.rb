class CreatePlanetCreatures < ActiveRecord::Migration
  def change
    create_table :planet_creatures do |t|
      t.references :user, index: true, foreign_key: true
      t.references :planet, index: true, foreign_key: true
      t.references :creature, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
