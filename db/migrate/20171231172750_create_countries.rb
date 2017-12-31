class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name
      t.string :description
      t.string :other_names
      t.references :universe, index: true, foreign_key: true
      t.string :population
      t.string :currency
      t.string :laws
      t.string :sports
      t.string :area
      t.string :crops
      t.string :climate
      t.string :founding_story
      t.string :established_year
      t.string :notable_wars
      t.string :notes
      t.string :private_notes

      t.timestamps null: false
    end
  end
end
