class AddFavoritePageTypeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :favorite_page_type, :string
  end
end
