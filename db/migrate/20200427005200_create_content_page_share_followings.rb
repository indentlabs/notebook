class CreateContentPageShareFollowings < ActiveRecord::Migration[6.0]
  def change
    create_table :content_page_share_followings do |t|
      t.references :content_page_share, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
