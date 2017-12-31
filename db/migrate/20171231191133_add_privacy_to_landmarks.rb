class AddPrivacyToLandmarks < ActiveRecord::Migration
  def change
    add_column :landmarks, :privacy, :string
  end
end
