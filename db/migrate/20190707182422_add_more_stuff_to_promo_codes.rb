class AddMoreStuffToPromoCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :page_unlock_promo_codes, :internal_description, :string
    add_column :page_unlock_promo_codes, :description, :string
  end
end
