class AddUniverseIdIndexToCharacters < ActiveRecord::Migration[4.2]
  def change
    add_index :characters, :universe_id
  end
end
