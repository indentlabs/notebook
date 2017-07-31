class AddPrivacyToFlora < ActiveRecord::Migration
  def change
    add_column :floras, :privacy, :string
  end
end
