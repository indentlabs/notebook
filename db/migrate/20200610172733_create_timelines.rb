class CreateTimelines < ActiveRecord::Migration[6.0]
  def change
    create_table :timelines do |t|
      t.string :name
      t.references :universe, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :page_type, default: 'Timeline'
      t.datetime :deleted_at
      t.datetime :archived_at
      t.string :privacy, default: 'private'

      t.timestamps
    end
  end
end
