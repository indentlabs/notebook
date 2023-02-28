class AddFinalSettingsToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :final_settings, :json
  end
end
