class AddUniverseAndContentTypeIndexToPageCategories < ActiveRecord::Migration
  def change
    add_index :page_categories, [:universe_id, :content_type]
  end
end
