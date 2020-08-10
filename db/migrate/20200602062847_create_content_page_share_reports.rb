class CreateContentPageShareReports < ActiveRecord::Migration[6.0]
  def change
    create_table :content_page_share_reports do |t|
      t.references :content_page_share, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :approved_at

      t.timestamps
    end
  end
end
