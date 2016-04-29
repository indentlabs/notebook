class CreateSiblingships < ActiveRecord::Migration
  def change
    create_table :siblingships do |t|
      t.integer :character_id
      t.integer :sibling_id

      t.timestamps null: false
    end
  end
end
