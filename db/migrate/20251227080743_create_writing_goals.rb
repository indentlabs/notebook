class CreateWritingGoals < ActiveRecord::Migration[6.1]
  def change
    create_table :writing_goals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :target_word_count, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.boolean :active, default: true
      t.datetime :completed_at

      t.timestamps
    end

    add_index :writing_goals, [:user_id, :active]
  end
end
