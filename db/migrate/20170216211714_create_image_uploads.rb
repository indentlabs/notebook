class CreateImageUploads < ActiveRecord::Migration
  def change
    create_table :image_uploads do |t|
      t.string :privacy
      t.references :user, index: true, foreign_key: true
      t.string :content_type
      t.integer :content_id

      t.timestamps null: false
    end
  end
end
