class CreateLandmarkNearbyTowns < ActiveRecord::Migration
  def change
    create_table :landmark_nearby_towns do |t|
      t.references :user, index: true, foreign_key: true
      t.references :landmark, index: true, foreign_key: true
      t.integer :nearby_town_id

      t.timestamps null: false
    end
  end
end
