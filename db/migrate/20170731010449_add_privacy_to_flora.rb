class AddPrivacyToFlora < ActiveRecord::Migration[4.2]
  def change
    add_column :floras, :privacy, :string
  end
end
