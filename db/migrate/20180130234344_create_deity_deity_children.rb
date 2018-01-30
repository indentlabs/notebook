class CreateDeityDeityChildren < ActiveRecord::Migration
  def change
    create_table :deity_deity_children do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true
      t.integer :deity_child_id

      t.timestamps null: false
    end
  end
end
