class CreateContentPageShares < ActiveRecord::Migration[6.0]
  def change
    create_table :content_page_shares do |t|
      t.references :user, null: false, foreign_key: true
      t.references :content_page, polymorphic: true, null: true, index: { name: :cps_index }
      t.datetime :shared_at
      t.string :privacy
      t.string :message

      t.timestamps
    end
  end
end
