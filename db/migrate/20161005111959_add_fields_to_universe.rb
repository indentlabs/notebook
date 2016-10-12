class AddFieldsToUniverse < ActiveRecord::Migration
  def change
    add_column :universes, :laws_of_physics, :string
    add_column :universes, :magic_system, :string
    add_column :universes, :technologies, :string
  end
end
