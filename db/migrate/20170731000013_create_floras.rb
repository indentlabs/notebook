class CreateFloras < ActiveRecord::Migration[4.2]
  def change
    create_table :floras do |t|
      t.string :name
      t.string :description
      t.string :aliases
      t.string :order
      t.string :family
      t.string :genus
      t.string :colorings
      t.string :size
      t.string :smell
      t.string :taste
      t.string :fruits
      t.string :seeds
      t.string :nuts
      t.string :berries
      t.string :medicinal_purposes
      t.string :reproduction
      t.string :seasonality

      t.timestamps null: false
    end
  end
end
