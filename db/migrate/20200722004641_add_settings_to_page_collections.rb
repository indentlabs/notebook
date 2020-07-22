class AddSettingsToPageCollections < ActiveRecord::Migration[6.0]
  def change
    add_column :page_collections, :allow_submissions, :boolean, default: false
    add_column :page_collections, :slug, :string
  end
end
