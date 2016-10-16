class CreateScenes < ActiveRecord::Migration
  def change
    create_table :scenes do |t|
      t.integer :scene_number
      t.string :name
      t.string :summary
      t.integer :universe_id
      t.integer :user_id
      t.string :cause
      t.string :description
      t.string :results
      t.string :prose
      t.string :notes
      t.string :private_notes

      t.timestamps null: false
    end
  end
end
