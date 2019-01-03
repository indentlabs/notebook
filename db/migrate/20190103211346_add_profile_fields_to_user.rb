class AddProfileFieldsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :bio, :string
    add_column :users, :favorite_author, :string
    add_column :users, :favorite_genre, :string
    add_column :users, :location, :string
    add_column :users, :age, :string
    add_column :users, :gender, :string
    add_column :users, :interests, :string
  end
end
