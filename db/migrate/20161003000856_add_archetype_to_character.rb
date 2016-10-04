class AddArchetypeToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :archetype, :string
  end
end
