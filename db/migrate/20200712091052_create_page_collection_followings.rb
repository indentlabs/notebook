class CreatePageCollectionFollowings < ActiveRecord::Migration[6.0]
  def change
    create_table :page_collection_followings do |t|
      t.references :page_collection, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
