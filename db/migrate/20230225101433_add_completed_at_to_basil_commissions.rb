class AddCompletedAtToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :completed_at, :datetime
  end
end
