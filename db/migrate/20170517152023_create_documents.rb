class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :user, index: true, foreign_key: true
      t.text :body

      t.timestamps null: false
    end
  end
end
