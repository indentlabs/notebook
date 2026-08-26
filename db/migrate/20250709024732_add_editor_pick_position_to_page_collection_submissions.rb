class AddEditorPickPositionToPageCollectionSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :page_collection_submissions, :editor_pick_position, :integer
    add_index :page_collection_submissions, [:page_collection_id, :editor_pick_position], 
              unique: true, where: "editor_pick_position IS NOT NULL",
              name: 'index_page_collection_submissions_on_editor_pick_position'
  end
end
