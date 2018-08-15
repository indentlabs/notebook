class CreateFloraRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :flora_relationships do |t|
      t.integer :flora_id
      t.integer :related_flora_id

      t.timestamps null: false
    end
  end
end
