class AddPrivacyToReligions < ActiveRecord::Migration
  def change
    add_column :religions, :privacy, :string
  end
end
