class AddCachedWordCountsToWorldbuildingPages < ActiveRecord::Migration[6.1]
  def change
    Rails.application.config.content_types[:all].each do |content_type|
      add_column            content_type.name.downcase.pluralize, :cached_word_count, :integer           # Add column without default lock
      change_column_default content_type.name.downcase.pluralize, :cached_word_count, from: nil, to: 0   # Add default value
      change_column_null    content_type.name.downcase.pluralize, :cached_word_count, true               # Ensure null is still allowed (for now)
    end
  end
end
