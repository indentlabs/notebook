class CreateCustomPages < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_pages do |t|
      t.string :name
      t.string :page_type
      t.references :universe, foreign_key: true
      t.references :user, foreign_key: true
      t.string :privacy
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
