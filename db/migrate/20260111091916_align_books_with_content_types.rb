class AlignBooksWithContentTypes < ActiveRecord::Migration[6.1]
  def change
    # Rename title to name for consistency with other content types
    rename_column :books, :title, :name

    # Add missing columns required by polymorphic_content_fields
    add_column :books, :favorite, :boolean, default: false, null: false
    add_column :books, :page_type, :string, default: 'Book'
    add_column :books, :cached_word_count, :integer, default: 0
  end
end
