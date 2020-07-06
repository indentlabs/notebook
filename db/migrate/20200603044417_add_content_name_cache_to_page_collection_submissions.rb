class AddContentNameCacheToPageCollectionSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :page_collection_submissions, :cached_content_name, :string
  end
end
