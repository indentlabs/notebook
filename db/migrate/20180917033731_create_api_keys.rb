class CreateApiKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :api_keys do |t|
      t.references :user, foreign_key: true
      t.string :key

      t.timestamps
    end
  end
end
