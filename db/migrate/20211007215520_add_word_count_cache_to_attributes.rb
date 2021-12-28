class AddWordCountCacheToAttributes < ActiveRecord::Migration[6.0]
  def change
    add_column :attributes, :word_count_cache, :integer
  end
end
