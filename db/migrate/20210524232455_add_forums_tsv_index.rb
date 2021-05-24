class AddForumsTsvIndex < ActiveRecord::Migration[6.0]
  def up
    add_column :thredded_posts, :tsv, :tsvector
    add_index :thredded_posts, :tsv, using: "gin"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON thredded_posts FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', title, content
      );
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE thredded_posts SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON thredded_posts
    SQL

    remove_index :thredded_posts, :tsv
    remove_column :thredded_posts, :tsv
  end
end
