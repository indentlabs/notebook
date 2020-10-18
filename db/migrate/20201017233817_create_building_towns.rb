class CreateBuildingTowns < ActiveRecord::Migration[6.0]
  def change
    create_table :building_towns do |t|
      t.integer :building_id
      t.integer :town_id
      t.integer :user_id

      t.timestamps
    end
  end
end
