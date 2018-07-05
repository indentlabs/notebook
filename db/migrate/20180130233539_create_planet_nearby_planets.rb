class CreatePlanetNearbyPlanets < ActiveRecord::Migration[4.2]
  def change
    create_table :planet_nearby_planets do |t|
      t.references :user, index: true, foreign_key: true
      t.references :planet, index: true, foreign_key: true
      t.integer :nearby_planet_id

      t.timestamps null: false
    end
  end
end
