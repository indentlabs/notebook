class CreateBuildingSchools < ActiveRecord::Migration[6.0]
  def change
    create_table :building_schools do |t|
      t.integer :building_id
      t.integer :district_school_id
      t.integer :user_id

      t.timestamps
    end
  end
end
