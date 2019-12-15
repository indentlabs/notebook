class AddJan2020ProfileFieldsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :favorite_book, :string
    add_column :users, :website, :string
    add_column :users, :inspirations, :string
    add_column :users, :other_names, :string
    add_column :users, :favorite_quote, :string
  end
end
