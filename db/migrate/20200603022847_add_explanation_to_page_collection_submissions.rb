class AddExplanationToPageCollectionSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :page_collection_submissions, :explanation, :string
  end
end
