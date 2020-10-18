class CreateBuildingLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :building_locations do |t|
      t.integer :building_id
      t.integer :location_id
      t.integer :user_id

      t.timestamps
    end
  end
end
