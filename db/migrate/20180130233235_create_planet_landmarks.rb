class CreatePlanetLandmarks < ActiveRecord::Migration
  def change
    create_table :planet_landmarks do |t|
      t.references :user, index: true, foreign_key: true
      t.references :planet, index: true, foreign_key: true
      t.references :landmark, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
