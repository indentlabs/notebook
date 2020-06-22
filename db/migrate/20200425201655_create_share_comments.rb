class CreateShareComments < ActiveRecord::Migration[6.0]
  def change
    create_table :share_comments do |t|
      t.references :user, null: true, foreign_key: true
      t.references :content_page_share, null: false, foreign_key: true
      t.string :message
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
