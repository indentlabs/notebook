class CreateLandmarks < ActiveRecord::Migration
  def change
    create_table :landmarks do |t|
      t.string :name
      t.string :description
      t.string :other_names
      t.references :universe, index: true, foreign_key: true
      t.string :size
      t.string :materials
      t.string :colors
      t.string :creation_story
      t.string :established_year
      t.string :notes
      t.string :private_notes

      t.timestamps null: false
    end
  end
end
