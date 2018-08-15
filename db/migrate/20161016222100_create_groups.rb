class CreateGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :description
      t.string :other_names
      t.integer :universe_id
      t.integer :user_id
      t.string :organization_structure
      t.string :motivation
      t.string :goal
      t.string :obstacles
      t.string :risks
      t.string :inventory
      t.string :notes
      t.string :private_notes

      t.timestamps null: false
    end
  end
end
