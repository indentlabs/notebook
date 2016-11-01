class CreateMagics < ActiveRecord::Migration
  def change
    drop_table :magics
    create_table :magics do |t|
      t.string :name
      t.string :description
      t.string :type_of
      t.integer :universe_id
      t.integer :user_id
      t.string :visuals
      t.string :effects
      t.string :positive_effects
      t.string :negative_effects
      t.string :neutral_effects
      t.string :element
      t.string :resource_costs
      t.string :materials
      t.string :skills_required
      t.string :limitations
      t.string :notes
      t.string :private_notes

      t.timestamps null: false
    end
  end
end
