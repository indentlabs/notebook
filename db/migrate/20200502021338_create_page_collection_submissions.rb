class CreatePageCollectionSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :page_collection_submissions do |t|
      t.references :content, polymorphic: true, null: false, index: { name: :polycontent_collection_index }
      t.references :user, null: false, foreign_key: true
      t.datetime :accepted_at
      t.datetime :submitted_at
      t.references :page_collection, null: false

      t.timestamps
    end
  end
end
