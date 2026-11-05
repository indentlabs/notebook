# Passwords for password protected pages (characters, locations, universes, and so on) live in
# their own table rather than a column on each of the page tables. That's one migration instead of
# one per page type, and it keeps the digest out of everything that serializes a page's columns:
# render json:, exports, RailsAdmin and the changelog.
class CreatePagePasswords < ActiveRecord::Migration[6.1]
  def change
    create_table :page_passwords do |t|
      t.references :page, polymorphic: true, null: false, index: { unique: true }
      t.string :password_digest, null: false

      t.timestamps
    end
  end
end
