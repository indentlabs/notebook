class CreateContinents < ActiveRecord::Migration[6.0]
  def change
    create_table :continents do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.references :universe, null: false, foreign_key: true
      t.datetime :deleted_at
      t.string :privacy
      t.string :page_type, default: 'Continent'

      t.timestamps
    end
  end
end
