class AddSavedAtToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :saved_at, :datetime
  end
end
