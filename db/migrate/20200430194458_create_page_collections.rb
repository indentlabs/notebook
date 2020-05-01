class CreatePageCollections < ActiveRecord::Migration[6.0]
  def change
    create_table :page_collections do |t|
      t.string :title
      t.string :subtitle
      t.references :user, null: false, foreign_key: true
      t.string :privacy
      t.string :page_types
      t.string :color
      t.string :cover_image
      t.boolean :auto_accept, default: false

      t.timestamps
    end
  end
end
