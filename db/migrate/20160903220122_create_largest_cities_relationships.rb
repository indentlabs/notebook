class CreateLargestCitiesRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :largest_cities_relationships do |t|
      t.integer :user_id
      t.integer :location_id
      t.integer :largest_city_id
    end
  end
end
