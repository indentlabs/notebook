class CreateTownCitizens < ActiveRecord::Migration[4.2]
  def change
    create_table :town_citizens do |t|
      t.references :user, index: true, foreign_key: true
      t.references :town, index: true, foreign_key: true
      t.integer :citizen_id

      t.timestamps null: false
    end
  end
end
