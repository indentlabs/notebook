class CreateUserBlockings < ActiveRecord::Migration[6.0]
  def change
    create_table :user_blockings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :blocked_user, null: false, index: true

      t.timestamps
    end
  end
end
