class CreatePromotions < ActiveRecord::Migration[5.2]
  def change
    create_table :promotions do |t|
      t.references :user, foreign_key: true
      t.references :page_unlock_promo_code, foreign_key: true
      t.datetime :expires_at
      t.string :content_type

      t.timestamps
    end
  end
end
