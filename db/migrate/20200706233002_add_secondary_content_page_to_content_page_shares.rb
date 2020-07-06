class AddSecondaryContentPageToContentPageShares < ActiveRecord::Migration[6.0]
  def change
    add_reference :content_page_shares, :secondary_content_page, polymorphic: true, null: true, index: { name: 'index_secondary_content_page_share' }
  end
end
