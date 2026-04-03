class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.references :user, null: false, foreign_key: true
      t.references :universe, foreign_key: true
      t.string :title
      t.string :subtitle
      t.text :description
      t.text :blurb
      t.integer :status, default: 0
      t.string :privacy, default: 'private'
      t.datetime :archived_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :books, [:user_id, :deleted_at]
  end
end
