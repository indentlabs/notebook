class CreateUserFollowings < ActiveRecord::Migration[6.0]
  def change
    create_table :user_followings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :followed_user, null: false, index: true

      t.timestamps
    end
  end
end
