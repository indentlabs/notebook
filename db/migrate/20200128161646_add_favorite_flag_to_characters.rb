class AddFavoriteFlagToCharacters < ActiveRecord::Migration[6.0]
  def change
    add_column :characters, :favorite, :boolean
  end
end
