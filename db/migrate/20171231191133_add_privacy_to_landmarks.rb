class AddPrivacyToLandmarks < ActiveRecord::Migration[4.2]
  def change
    add_column :landmarks, :privacy, :string
  end
end
