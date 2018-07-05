class AddUniverseIndices < ActiveRecord::Migration[4.2]
  def change
    add_index :magics, :universe_id
    add_index :scenes, :universe_id
    add_index :religions, :universe_id
    add_index :languages, :universe_id
    add_index :groups, :universe_id
    add_index :creatures, :universe_id
    add_index :items, :universe_id
    add_index :locations, :universe_id
  end
end
