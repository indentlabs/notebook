class CreateTraditions < ActiveRecord::Migration[5.2]
  def change
    create_table :traditions do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.references :universe, foreign_key: true
      t.datetime :deleted_at
      t.string :privacy
      t.string :page_type, default: 'Tradition'

      t.timestamps
    end
  end
end
