class CreatePageTags < ActiveRecord::Migration[5.2]
  def change
    create_table :page_tags do |t|
      t.references :page, polymorphic: true
      t.string :tag
      t.string :slug
      t.string :color
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
