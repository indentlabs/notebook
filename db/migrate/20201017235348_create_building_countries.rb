class CreateBuildingCountries < ActiveRecord::Migration[6.0]
  def change
    create_table :building_countries do |t|
      t.integer :building_id
      t.integer :country_id
      t.integer :user_id

      t.timestamps
    end
  end
end
