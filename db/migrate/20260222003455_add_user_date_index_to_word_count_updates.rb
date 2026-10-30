class AddUserDateIndexToWordCountUpdates < ActiveRecord::Migration[6.1]
  def change
    add_index :word_count_updates, [:user_id, :for_date], name: 'idx_word_count_user_date'
  end
end
