class AddGenreToUniverse < ActiveRecord::Migration[4.2]
  def change
    add_column :universes, :genre, :string
  end
end
