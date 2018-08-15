class CreateFloraLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :flora_locations do |t|
      t.integer :flora_id
      t.integer :location_id

      t.timestamps null: false
    end
  end
end
