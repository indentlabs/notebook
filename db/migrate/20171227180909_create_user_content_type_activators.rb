class CreateUserContentTypeActivators < ActiveRecord::Migration
  def change
    create_table :user_content_type_activators do |t|
      t.references :user, index: true, foreign_key: true
      t.string :content_type

      t.timestamps null: false
    end
  end
end
