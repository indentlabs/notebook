class AddDescriptionToPageCollections < ActiveRecord::Migration[6.0]
  def change
    add_column :page_collections, :description, :string
  end
end
