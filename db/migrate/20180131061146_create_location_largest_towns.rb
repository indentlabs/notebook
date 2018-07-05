class CreateLocationLargestTowns < ActiveRecord::Migration[4.2]
  def change
    create_table :location_largest_towns do |t|
      t.references :location, index: true, foreign_key: true
      t.integer :largest_town_id
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
