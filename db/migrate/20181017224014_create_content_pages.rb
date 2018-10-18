class CreateContentPages < ActiveRecord::Migration[5.2]
  def change
    create_table :content_pages do |t|
      t.string :name
      t.string :description
      t.references :user, foreign_key: true
      t.references :universe, foreign_key: true
      t.datetime :deleted_at
      t.string :privacy
      t.string :page_type

      t.timestamps
    end
  end
end
