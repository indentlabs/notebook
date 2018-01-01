class CreateTownNearbyLandmarks < ActiveRecord::Migration
  def change
    create_table :town_nearby_landmarks do |t|
      t.references :user, index: true, foreign_key: true
      t.references :town, index: true, foreign_key: true
      t.integer :nearby_landmark_id

      t.timestamps null: false
    end
  end
end
