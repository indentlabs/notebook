class CreateOmniauthUsers < ActiveRecord::Migration
  def change
    create_table :omniauth_users do |t|
      t.string :provider
      t.string :uid
      t.string :email
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
