class CreateBuildingLandmarks < ActiveRecord::Migration[6.0]
  def change
    create_table :building_landmarks do |t|
      t.integer :building_id
      t.integer :landmark_id
      t.integer :user_id

      t.timestamps
    end
  end
end
