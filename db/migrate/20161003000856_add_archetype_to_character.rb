class AddArchetypeToCharacter < ActiveRecord::Migration[4.2]
  def change
    add_column :characters, :archetype, :string
  end
end
