class CreateFolders < ActiveRecord::Migration[6.0]
  def change
    create_table :folders do |t|
      t.string :title,   default: 'New Folder'
      t.string :context, default: 'Document'
      t.references :parent_folder, null: true, foreign_key: { to_table: :folders }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
