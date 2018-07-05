class AddFluidPreferenceToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :fluid_preference, :boolean
  end
end
