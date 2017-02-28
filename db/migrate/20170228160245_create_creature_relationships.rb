class CreateCreatureRelationships < ActiveRecord::Migration
  def change
    create_table :creature_relationships do |t|
      t.integer :user_id
      t.integer :creature_id
      t.integer :related_creature_id

      t.timestamps null: false
    end
  end
end
