class AddDeletedAtToContentPageShares < ActiveRecord::Migration[6.0]
  def change
    add_column :content_page_shares, :deleted_at, :datetime
  end
end
