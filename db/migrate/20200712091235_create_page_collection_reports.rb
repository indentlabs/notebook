class CreatePageCollectionReports < ActiveRecord::Migration[6.0]
  def change
    create_table :page_collection_reports do |t|
      t.references :page_collection, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :approved_at

      t.timestamps
    end
  end
end
