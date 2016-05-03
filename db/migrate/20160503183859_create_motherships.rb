class CreateMotherships < ActiveRecord::Migration
  def change
    create_table :motherships do |t|
      t.integer :user_id
      t.integer :character_id
      t.integer :mother_id

      t.timestamps null: false
    end
  end
end
