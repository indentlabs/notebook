class AddCachedSecondsTakenToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :cached_seconds_taken, :float
  end
end
