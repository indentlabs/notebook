class CreateCapitalCitiesRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :capital_cities_relationships do |t|
      t.integer :user_id
      t.integer :location_id
      t.integer :capital_city_id
    end
  end
end
