class CreateDocuments < ActiveRecord::Migration[4.2]
  def change
    create_table :documents do |t|
      t.references :user, index: true, foreign_key: true
      t.text :body

      t.timestamps null: false
    end
  end
end
