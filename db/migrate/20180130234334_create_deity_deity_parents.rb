class CreateDeityDeityParents < ActiveRecord::Migration
  def change
    create_table :deity_deity_parents do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true
      t.integer :deity_parent_id

      t.timestamps null: false
    end
  end
end
