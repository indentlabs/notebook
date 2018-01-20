class AddUniverseIdIndexToCharacters < ActiveRecord::Migration
  def change
    add_index :characters, :universe_id
  end
end
