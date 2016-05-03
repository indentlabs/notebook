class CreateFatherships < ActiveRecord::Migration
  def change
    create_table :fatherships do |t|
      t.integer :user_id
      t.integer :character_id
      t.integer :father_id

      t.timestamps null: false
    end
  end
end
