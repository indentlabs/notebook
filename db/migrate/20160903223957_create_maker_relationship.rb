class CreateMakerRelationship < ActiveRecord::Migration[4.2]
  def change
    create_table :maker_relationships do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :maker_id
    end
  end
end
