class CreateReligions < ActiveRecord::Migration
  def change
    create_table :religions do |t|
      t.string :name
      t.string :description
      t.string :other_names
      t.integer :universe_id
      t.integer :user_id
      t.string :origin_story
      t.string :teachings
      t.string :prophecies
      t.string :places_of_worship
      t.string :worship_services
      t.string :obligations
      t.string :paradise
      t.string :initiation
      t.string :rituals
      t.string :holidays
      t.string :notes
      t.string :private_notes

      t.timestamps null: false
    end
  end
end
