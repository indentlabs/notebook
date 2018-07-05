class CreateContentChangeEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :content_change_events do |t|
      t.references :user, index: true, foreign_key: true
      t.text :changed_fields
      t.integer :content_id
      t.string :content_type
      t.string :action

      t.timestamps null: false
    end
  end
end
