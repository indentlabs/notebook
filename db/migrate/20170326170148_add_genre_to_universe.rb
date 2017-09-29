class AddGenreToUniverse < ActiveRecord::Migration
  def change
    add_column :universes, :genre, :string
  end
end
