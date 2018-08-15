class AddMoreIndices < ActiveRecord::Migration[4.2]
  def change
    add_index :characters, :user_id
    add_index :universes, :user_id
    add_index :magics, :user_id
    add_index :scenes, :user_id
    add_index :religions, :user_id
    add_index :languages, :user_id
    add_index :groups, :user_id
    add_index :creatures, :user_id
    add_index :items, :user_id
    add_index :locations, :user_id

    add_index :image_uploads, [:content_type, :content_id]
  end
end
