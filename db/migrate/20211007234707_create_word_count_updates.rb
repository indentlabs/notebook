class CreateWordCountUpdates < ActiveRecord::Migration[6.0]
  def change
    create_table :word_count_updates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :entity, polymorphic: true, null: false
      t.integer :word_count
      t.date :for_date

      t.timestamps
    end
  end
end
