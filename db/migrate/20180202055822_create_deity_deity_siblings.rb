class CreateDeityDeitySiblings < ActiveRecord::Migration
  def change
    create_table :deity_deity_siblings do |t|
      t.references :deity, index: true, foreign_key: true
      t.integer :deity_sibling_id
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
