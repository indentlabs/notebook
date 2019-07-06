class CreatePromotions < ActiveRecord::Migration[5.2]
  def change
    create_table :promotions do |t|
      t.references :user, foreign_key: true
      t.integer :promo_code_id
      t.datetime :expires_at
      t.string :content_type

      t.timestamps
    end
  end
end
