class AddFavoriteToContinents < ActiveRecord::Migration[6.0]
  def change
    add_column :continents, :favorite, :boolean
  end
end
