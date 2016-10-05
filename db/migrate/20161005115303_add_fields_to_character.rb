class AddFieldsToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :aliases, :string
    add_column :characters, :motivations, :string
    add_column :characters, :flaws, :string
    add_column :characters, :talents, :string
    add_column :characters, :hobbies, :string
    add_column :characters, :personality_type, :string
  end
end
