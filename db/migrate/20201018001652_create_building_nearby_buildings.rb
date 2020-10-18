class CreateBuildingNearbyBuildings < ActiveRecord::Migration[6.0]
  def change
    create_table :building_nearby_buildings do |t|
      t.integer :building_id
      t.integer :nearby_building_id
      t.integer :user_id

      t.timestamps
    end
  end
end
