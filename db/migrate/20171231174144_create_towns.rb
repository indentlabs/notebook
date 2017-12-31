class CreateTowns < ActiveRecord::Migration
  def change
    create_table :towns do |t|
      t.string :name
      t.string :description
      t.string :other_names
      t.string :laws
      t.string :sports
      t.string :politics
      t.string :founding_story
      t.string :established_year
      t.string :notes
      t.string :private_notes

      t.timestamps null: false
    end
  end
end
